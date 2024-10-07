import Bool "mo:base/Bool";
import Func "mo:base/Func";
import Hash "mo:base/Hash";

import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Text "mo:base/Text";

actor {
  // Define the ShoppingItem type
  type ShoppingItem = {
    id: Nat;
    text: Text;
    completed: Bool;
  };

  // Stable variable to store shopping items
  stable var nextId: Nat = 0;
  stable var itemEntries: [(Nat, ShoppingItem)] = [];

  // Create a HashMap to store shopping items
  var shoppingItems = HashMap.HashMap<Nat, ShoppingItem>(0, Nat.equal, Nat.hash);

  // Function to add a new shopping item
  public func addItem(text: Text) : async Nat {
    let id = nextId;
    let newItem: ShoppingItem = {
      id = id;
      text = text;
      completed = false;
    };
    shoppingItems.put(id, newItem);
    nextId += 1;
    id
  };

  // Function to get all shopping items
  public query func getItems() : async [ShoppingItem] {
    Iter.toArray(shoppingItems.vals())
  };

  // Function to update an item's completed status
  public func updateItem(id: Nat, completed: Bool) : async Bool {
    switch (shoppingItems.get(id)) {
      case (null) { false };
      case (?item) {
        let updatedItem: ShoppingItem = {
          id = item.id;
          text = item.text;
          completed = completed;
        };
        shoppingItems.put(id, updatedItem);
        true
      };
    }
  };

  // Function to delete an item
  public func deleteItem(id: Nat) : async Bool {
    switch (shoppingItems.remove(id)) {
      case (null) { false };
      case (?_) { true };
    }
  };

  // System functions for upgrades
  system func preupgrade() {
    itemEntries := Iter.toArray(shoppingItems.entries());
  };

  system func postupgrade() {
    shoppingItems := HashMap.fromIter<Nat, ShoppingItem>(itemEntries.vals(), 0, Nat.equal, Nat.hash);
  };
}
