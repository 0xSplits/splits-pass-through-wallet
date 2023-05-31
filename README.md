# splits-pass-through-wallet

## What

Pass-through wallet is an ownable smart contract wallet with pausable token forwarding

## Why

Some onchain value flows require or benefit greatly from inserting full smart contract wallet functionality

## How

[![Sequence diagram of passThroughFunds](https://mermaid.ink/svg/pako:eNqNklFPwjAUhf9KU7PsQUiIDEb2sIQhezMx0eiD8-GyXaCxa7G9MxLCf3frgjBE40vb3Pud09707HiuC-QR97xdphgTSlDE3JExn9ZYoh8xfwEW_d5p9QmMgIVE63_jrrnUilIohdw2ugaSB2Erxk-aaalN074aJ-HNZNABNkaUYLZHJh2mQTq-xCTaFGj-dLOYa1V0_MbzeZiEl6lzx0EQTkZdFnISH0BCq3_AhIZE5_bpKAnS2UXo3C8YDiezqd-S-2arl73nZSpTFt8rVDneClgZKBui5aZS5NiP4-t7sPZxbXS1Wj-DlFh_6-ZYetRvqGwr-UH2a_1JMWIvjAwou0TDyAnZ62_SOO67J0QMSl0psrzHSzQliKJOmUtKxl2CMh7VxwKXUEnKeD1ajUJF-mGrch6RqbDHq00BdJjyUMRCkDZ3bXBdfvdfjQraHg)](https://mermaid.live/edit#pako:eNqNklFPwjAUhf9KU7PsQUiIDEb2sIQhezMx0eiD8-GyXaCxa7G9MxLCf3frgjBE40vb3Pud09707HiuC-QR97xdphgTSlDE3JExn9ZYoh8xfwEW_d5p9QmMgIVE63_jrrnUilIohdw2ugaSB2Erxk-aaalN074aJ-HNZNABNkaUYLZHJh2mQTq-xCTaFGj-dLOYa1V0_MbzeZiEl6lzx0EQTkZdFnISH0BCq3_AhIZE5_bpKAnS2UXo3C8YDiezqd-S-2arl73nZSpTFt8rVDneClgZKBui5aZS5NiP4-t7sPZxbXS1Wj-DlFh_6-ZYetRvqGwr-UH2a_1JMWIvjAwou0TDyAnZ62_SOO67J0QMSl0psrzHSzQliKJOmUtKxl2CMh7VxwKXUEnKeD1ajUJF-mGrch6RqbDHq00BdJjyUMRCkDZ3bXBdfvdfjQraHg)

### How does it forward funds?

Via an external, pausable function taking an array of tokens to forward (0x0 for ETH).

### How is it governed?

A PassThroughWallet's owner, if set, has FULL CONTROL of the deployment.
It may, at any time for any reason, change the passThrough, pause the flow, or execute arbitrary calls on behalf of the PassThroughWallet.
In situations where flows ultimately belong to or benefit more than a single person & immutability is a nonstarter, we strongly recommend using a multisig or DAO for governance.

## Lint

`forge fmt`

## Setup & test

`forge i` - install dependencies

`forge b` - compile the contracts

`forge t` - compile & test the contracts

`forge t -vvv` - produces a trace of any failing tests

## Natspec

`forge doc --serve --port 4000` - serves natspec docs at http://localhost:4000/
