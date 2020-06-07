pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract evoicing {

  /// The seller's address
  address  owner;

  /// The buyer's address part on this contract
  address  buyerAddr;

  /// The Buyer struct  
  struct Buyer {
    address addr;
    string name;

    bool init;
  }

  /// The Shipment struct
  struct Shipment {
    address courier;
    uint price;
    uint safepay;
    address payer;
    uint date;
    uint real_date;

    bool init;
  }

  /// The Order struct
  struct Order {
    string goods;
    uint quantity;
    uint number;
    uint price;
    uint safepay;
    Shipment shipment;

    bool init;
  }

  /// The Invoice struct
  struct Invoice {
    uint orderno;
    uint number;

    bool init;
  }

  /// The mapping to store orders
  mapping (uint => Order) orders;

  /// The mapping to store invoices
  mapping (uint => Invoice) invoices;

  /// The sequence number of orders
  uint orderseq;

  /// The sequence number of invoices
  uint invoiceseq;

  /// Event triggered for every registered buyer
  event BuyerRegistered(address buyer, string name);

  /// Event triggered for every new order
  event OrderSent(address buyer, string goods, uint quantity, uint orderno);

  /// Event triggerd when the order gets valued and wants to know the value of the payment
  event PriceSent(address buyer, uint orderno, uint price, int8 ttype);

  /// Event trigger when the buyer performs the safepay
  event SafepaySent(address buyer, uint orderno, uint value, uint now);

  /// Event triggered when the seller sends the invoice
  event InvoiceSent(address buyer, uint invoiceno, uint orderno, uint delivery_date, address courier);

  /// Event triggered when the courie delives the order
  event OrderDelivered(address buyer, uint invoiceno, uint orderno, uint real_delivey_date, address courier);

  /// The smart contract's constructor
  constructor() public {
    
    /// The seller is the contract's owner
    owner = msg.sender;
  }

   /// Adding the buyer to the contract
  function addBuyer(address _buyerAddr)public {
      require(msg.sender == owner,"owner can call this function");
      buyerAddr = _buyerAddr;
  }
  
  /// Return the owner of the contract
  function Owner() public view returns(address){
      return owner;
  }
  
  /// Return the Buyer address that have economic relationship with seller
  function BuyerAddr() public view returns(address){
      return buyerAddr;
  }
  
  /// The function to send purchase orders
  ///   requires fee
  ///   Payable functions returns just the transaction object, with no custom field.
  ///   To get field values listen to OrderSent event.
  function sendOrder(string memory goods, uint quantity)  public  {
    
    /// Accept orders just from buyer
    require(msg.sender == BuyerAddr(), "buyer address can call this function" );

    /// Increment the order sequence
    orderseq++;

    /// Create the order register
    orders[orderseq] = Order(goods, quantity, orderseq, 0, 0, Shipment(address(0), 0, 0, address(0), 0, 0, false), true);

    /// Trigger the event
    emit OrderSent(msg.sender, goods, quantity, orderseq);

  }

  /// The function to query orders by number
  ///   Constant functions returns custom fields
  function queryOrder(uint number) public view returns (Order memory) {
    
    /// Validate the order number
    require(orders[number].init);

    /// Return the order data
    //return(buyerAddr, orders[number].goods, orders[number].quantity, orders[number].price, orders[number].safepay, orders[number].shipment.price, orders[number].shipment.safepay);
  
      return orders[number];
  }

  /// The function to send the price to pay for order
  ///  Just the owner can call this function
  ///  requires free
  function sendPrice(uint orderno, uint price, int8 ttype)  public  {
  
    /// Only the owner can use this function
    require(msg.sender == Owner(), "only owner can call thsi function");

    /// Validate the order number
    require(orders[orderno].init);

    /// Validate the type
    ///  1=order
    ///  2=shipment
    require(ttype == 1 || ttype == 2);

    if(ttype == 1){/// Price for Order

      /// Update the order price
      orders[orderno].price = price;

    } else {/// Price for Shipment

      /// Update the shipment price
      orders[orderno].shipment.price = price;
      orders[orderno].shipment.init  = true;
    }

    /// Trigger the event
    emit PriceSent(buyerAddr, orderno, price, ttype);

  }

  /// The function to send the value of order's price
  ///  This value will be blocked until the delivery of order
  ///  requires fee
  function sendSafepay(uint orderno) payable public {

    /// Validate the order number
    require(orders[orderno].init);

    /// Just the buyer can make safepay
    require(buyerAddr == msg.sender,"only buyer can call this function");

    /// The order's value plus the shipment value must equal to msg.value
    require((orders[orderno].price + orders[orderno].shipment.price) == msg.value);

    orders[orderno].safepay = msg.value;

    emit SafepaySent(msg.sender, orderno, msg.value, now);
  }

  /// The function to send the invoice data
  ///  requires fee
  function sendInvoice(uint orderno, uint delivery_date, address courier) public {

    /// Validate the order number
    require(orders[orderno].init);

    /// Just the seller can send the invoice
    require(owner == msg.sender);

    invoiceseq++;

    /// Create then Invoice instance and store it
    invoices[invoiceseq] = Invoice(orderno, invoiceseq, true);

    /// Update the shipment data
    orders[orderno].shipment.date    = delivery_date;
    orders[orderno].shipment.courier = courier;

    /// Trigger the event
    emit InvoiceSent(buyerAddr, invoiceseq, orderno, delivery_date, courier);
  }

  /// The function to get the sent invoice
  ///  requires no fee
  function getInvoice(uint invoiceno) public view returns (address buyer, uint orderno, uint delivery_date, address courier){
  
    /// Validate the invoice number
    require(invoices[invoiceno].init);

    Invoice storage _invoice = invoices[invoiceno];
    Order storage _order     = orders[_invoice.orderno];

    return (buyerAddr, _order.number, _order.shipment.date, _order.shipment.courier);
  }

  /// The function to mark an order as delivered
  function delivery(uint invoiceno, uint timestamp) payable public {

    /// Validate the invoice number
    require(invoices[invoiceno].init);

    Invoice storage _invoice = invoices[invoiceno];
    Order storage _order     = orders[_invoice.orderno];

    /// Just the courier can call this function
    require(_order.shipment.courier == msg.sender, "only courier can call thhis function");

    emit OrderDelivered(buyerAddr, invoiceno, _order.number, timestamp, _order.shipment.courier);

    /// Payout the Order to the seller
    payable(owner).transfer(_order.safepay);

    /// Payout the Shipment to the courier
    payable(_order.shipment.courier).transfer(_order.shipment.safepay);

  }

}