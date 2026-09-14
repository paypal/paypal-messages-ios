# Using PayPal Messages in a reusable list

How to put a PayPal message inside a `UITableView` or `UICollectionView` cell, when the
banner must be invisible until its content is ready and the row has to grow to fit it.

This answers [#44](https://github.com/paypal/paypal-messages-ios/issues/44). If you use
`BTPayPalMessagingView` from the Braintree SDK, it wraps `PayPalMessageView`, so the same
constraints apply.

## The conflict

A message loads asynchronously. Revealing it later means changing the row's height, and on
iOS that means updating the table — which is free to hand a different cell instance to that
index. If the view lives inside a cell, the view that just became ready and the cell now on
screen for that product may no longer be the same object.

## Four facts that decide the design

These follow from how `PayPalMessageView` works today, and each one rules an option in or
out:

1. **Creating the view starts the fetch.** `PayPalMessageView(config:stateDelegate:eventDelegate:)`
   begins loading immediately; there is no separate `start()` to defer it. A view you create
   early is a fetch you started early — which is what makes prefetching possible.
2. **A loading view is already ~zero-height.** `intrinsicContentSize` returns the internal
   label's, and the label has no text until content arrives. You do not need to hide the view
   or reserve a placeholder box: an unresolved message occupies no vertical space on its own.
3. **`setConfig(_:)` always refetches**, by design, even for an identical config. Calling it
   during cell reuse throws away resolved content and starts the network again. Never call it
   on a view you are merely re-parenting.
4. **There is no client-side cache of message content.** The merchant profile is cached, the
   message is not. Every `PayPalMessageView` you create is its own network request, so the
   number of views you create is the number of requests you make.

## Recommended ownership: one view per config, owned outside the cell

Tying the view to the cell (approach 1 in the issue) cannot be made correct — cell instance
identity is not stable across an update, and no UIKit API lets you say "attach this specific
view to whichever cell now represents product X".

Tying the view to the config (approach 2) is the right model. The reported jank comes not
from that choice but from *reloading the list once per ready event*. Three changes remove it.

### 1. Prefetch, so content is usually ready before the row is displayed

Because construction starts the fetch and an unresolved view is harmless, create views ahead
of display rather than at `cellForRowAt`:

```swift
final class MessageStore {
    private var views: [ProductID: PayPalMessageView] = [:]

    /// Starts loading if it hasn't started. Safe to call repeatedly.
    func prefetch(_ id: ProductID, config: PayPalMessageConfig, delegate: PayPalMessageViewStateDelegate) {
        guard views[id] == nil else { return }
        views[id] = PayPalMessageView(config: config, stateDelegate: delegate)
    }

    func view(for id: ProductID) -> PayPalMessageView? { views[id] }
}

extension ProductListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for path in indexPaths {
            let product = products[path.row]
            store.prefetch(product.id, config: product.messageConfig, delegate: self)
        }
    }
}
```

By the time the row scrolls in, the message has usually resolved and the row is laid out at
its final height once, with no update at all.

### 2. Coalesce the ready events into one update

When a message does resolve while its row is on screen, do not reload immediately. Collect
the ready ids and apply a single update per runloop turn:

```swift
func onSuccess(_ paypalMessageView: PayPalMessageView) {
    guard let id = id(of: paypalMessageView) else { return }
    pendingReady.insert(id)
    scheduleFlush()
}

private func scheduleFlush() {
    guard !flushScheduled else { return }
    flushScheduled = true
    DispatchQueue.main.async { [weak self] in   // one flush per runloop turn
        guard let self else { return }
        self.flushScheduled = false
        let ready = self.pendingReady
        self.pendingReady.removeAll()
        guard !ready.isEmpty else { return }
        self.applySnapshot(reconfiguring: ready)
    }
}
```

Ten banners resolving in the same turn produce one snapshot, not ten. Prefer
`reconfigureItems(_:)` (iOS 15+) over `reloadItems(_:)`: it updates the existing cells in
place instead of recreating them, which is both cheaper and keeps the cell instance stable.

### 3. Re-parent the cached view; never reconfigure it

On `cellForRowAt`, move the stored view into the cell. Because a loading view is zero-height
(fact 2), the same code path works whether or not it has resolved — there is no "hidden"
state to manage:

```swift
func configure(with view: PayPalMessageView?) {
    messageContainer.subviews.forEach { $0.removeFromSuperview() }
    guard let view else { return }
    view.removeFromSuperview()          // detach from whichever cell had it
    messageContainer.addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        view.topAnchor.constraint(equalTo: messageContainer.topAnchor),
        view.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor),
        view.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor),
        view.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor)
    ])
}
```

Note what is *absent*: no `setConfig`, no `isHidden` toggling, no stored height. The cell
reads the view's intrinsic size through self-sizing, so the row is correct in both states.

A view has exactly one superview, so a given message appears in one cell at a time. That is
what you want here — one config maps to one row.

## Keep the store bounded

Every entry is a network request and a retained view, so an unbounded store over a long list
is a leak in all but name. Evict on a windowed or LRU policy — for example, drop entries far
outside the visible range in `tableView(_:cancelPrefetchingForRowsAt:)` — and re-prefetch if
the user scrolls back. Re-creating the view re-requests the message; there is no cache to
fall back on (fact 4).

## Checklist

- [ ] The view is owned by a store keyed on config/product, never by the cell.
- [ ] Views are created in `prefetchRowsAt`, not in `cellForRowAt`.
- [ ] Ready events are coalesced into one update per runloop turn.
- [ ] Updates use `reconfigureItems(_:)` rather than `reloadItems(_:)`.
- [ ] `setConfig(_:)` is never called during reuse.
- [ ] Cells re-parent the view and let self-sizing read its intrinsic height.
- [ ] The store is bounded.

## Current limitations

Two things this pattern works around rather than solves, both of which are API gaps:

- **Content cannot be resolved without a view.** Fetching lives in the view's model, so
  "does this product have a message, and how tall is it" cannot be answered before a
  `PayPalMessageView` exists. A headless fetch would let a data source compute row heights up
  front and remove the height change entirely.
- **There is no content cache.** Two views for the same config issue two requests, and a view
  evicted and recreated refetches.

Both are tracked in [#44](https://github.com/paypal/paypal-messages-ios/issues/44).
