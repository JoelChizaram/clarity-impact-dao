import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure that proposal creation works",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("dao-core", "create-proposal",
        [
          types.ascii("Test Proposal"),
          types.utf8("Description"),
          types.uint(1000),
          types.principal(deployer.address)
        ],
        deployer.address
      ),
    ]);
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
  },
});
