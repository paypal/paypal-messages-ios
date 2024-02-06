/// Message location within an application
public enum PayPalMessagePageType: String, CaseIterable {
    /// Home view
    case home
    /// Multiple products listing view
    case productListing = "product-listing"
    /// Individual product details view
    case productDetails = "product-details"
    /// Shopping cart view
    case cart
    /// Popover shopping cart view that covers part of the view
    case miniCart = "mini-cart"
    /// Checkout view
    case checkout
    /// Search results
    case searchResults = "search-results"
}
