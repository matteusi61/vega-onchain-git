# Oncahin-git
## Функционал
1. **upgradeTo(address newImplementation)** - обновляет UUPsUpgradable контракт, добавляя в versionHistory адрес новой имплементации.
2. **rollBackTo()** - возращает к предыдушей версии UUPsUpgradable контракт.
3. **currentVersion** - public переменная, содержащая адрес текущей имплементации.

## Тест на Anvil
forge test --fork-url http://localhost:8545 --match-contract VersionManagerAnvilTest
[⠊] Compiling...
No files changed, compilation skipped

Ran 4 tests for test/VersionManagerAnvil.t.sol:VersionManagerAnvilTest
[PASS] testMultipleUpgrades() (gas: 483327)
[PASS] testRollback() (gas: 111204)
[PASS] testSecurity() (gas: 28532)
[PASS] testUpgrade() (gas: 127999)
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 65.79ms (74.49ms CPU time)

Ran 1 test suite in 183.86ms (65.79ms CPU time): 4 tests passed, 0 failed, 0 skipped (4 total tests)
