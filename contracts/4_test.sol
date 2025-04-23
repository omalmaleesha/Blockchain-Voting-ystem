// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SupplyChain {
    enum State { Created, Supplied, Distributed, Retailed }

    struct Product {
        uint id;
        string name;
        State state;
        address manufacturer;
        address supplier;
        address distributor;
        address retailer;
    }

    mapping(uint => Product) public products;
    uint public productCount;

    address public admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can assign roles");
        _;
    }

    modifier onlyManufacturer(uint productId) {
        require(msg.sender == products[productId].manufacturer, "Not the manufacturer");
        _;
    }

    modifier onlySupplier(uint productId) {
        require(msg.sender == products[productId].supplier, "Not the supplier");
        _;
    }

    modifier onlyDistributor(uint productId) {
        require(msg.sender == products[productId].distributor, "Not the distributor");
        _;
    }

    modifier onlyRetailer(uint productId) {
        require(msg.sender == products[productId].retailer, "Not the retailer");
        _;
    }

    // Admin creates the product and sets roles
    function createProduct(
        string memory name,
        address supplier,
        address distributor,
        address retailer
    ) public {
        products[productCount] = Product(
            productCount,
            name,
            State.Created,
            msg.sender,
            supplier,
            distributor,
            retailer
        );
        productCount++;
    }

    function supplyProduct(uint productId) public onlySupplier(productId) {
        require(products[productId].state == State.Created, "Product not ready for supply");
        products[productId].state = State.Supplied;
    }

    function distributeProduct(uint productId) public onlyDistributor(productId) {
        require(products[productId].state == State.Supplied, "Product not ready for distribution");
        products[productId].state = State.Distributed;
    }

    function retailProduct(uint productId) public onlyRetailer(productId) {
        require(products[productId].state == State.Distributed, "Product not ready for retail");
        products[productId].state = State.Retailed;
    }

    function getProduct(uint productId) public view returns (
        uint,
        string memory,
        State,
        address,
        address,
        address,
        address
    ) {
        Product memory p = products[productId];
        return (
            p.id,
            p.name,
            p.state,
            p.manufacturer,
            p.supplier,
            p.distributor,
            p.retailer
        );
    }
}
