# Full-Stack-Supply-Chain

E-voicing smart contract provides the better track the supply chain processing and to control overall efficiency.
E-invoice is used for Business- to - Business (B2B) and Business-to-Government(B2G)/ G2B. it includes the e-invoice exchange between supplier and buyer.
Method Description


Seller deploys the contracts for the buyer’s account


Buyer orders the goods with the definite quantity at the seller's smart contract. Through an event seller receives order data.


Seller looks for the best shipping price at the courier contract.


Seller sends the order price and shipment price and the buyer  receives this through the event.


Buyer sends the total payment(order + shipment) to the seller 's smart contract account.


Seller sends the invoice with a delivery date and other data and the buyer receives the invoice  through the event.


Courier after delivery the goods to the buyer, marks order as delivered on smart contract.


Smart contract pays out the seller for order and pays out the courier for shipment.


Dependencies


Node +6.11


NPM +3.10


Truffle +4.0.5


Ganache CLI +6.0.4


Deploy


In another terminal start the ganache using the following command
     ganache-cli


In another terminal compile it, deploy and test
    truffle compile

    truffle migrate

    truffle test


Testing


Install all the modules related testing file using following command
       npm install chai  --save
       npm install chai-as-promised --save
