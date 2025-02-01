import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure that token transfer works",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const wallet1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("governance-token", "mint", [types.uint(1000), types.principal(wallet1.address)], deployer.address),
    ]);
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    
    block = chain.mineBlock([
      Tx.contractCall("governance-token", "transfer", 
        [types.uint(500), types.principal(wallet1.address), types.principal(deployer.address)],
        wallet1.address
      ),
    ]);
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 3);
  },
});
