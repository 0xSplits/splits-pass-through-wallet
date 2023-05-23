# splits-pass-through-wallet

## What

Pass-through wallet is an ownable smart contract wallet with pausable-but-otherwise-permissionless fund forwarding

## Why

Some onchain value flows require or benefit greatly from inserting full smart contract wallet functionality

## How

[![Sequence diagram of passThroughFunds](https://mermaid.ink/img/pako:eNp1kM0KwjAQhF8l7NX2BXIoCF4FwYIH42Fptj-Yn5psDlL67qYtoiDuYVmG-WB2Jmi8JpAQ6ZHINXQYsAtoRR7llr03Q0NlVe1OGGPdB5-6_oLGEEsxfqTa38nFDflxlpn_EqW4Cg7oYktB8AqK2z-0qso1ghRofXIcoQBLweKgc-xpwRRwT5YUyHxqajEZVqDcnK2Y2J-frgHJIVEBadTI7y9BtmhiVkkP7MNxq2JtZH4BzOZhcA?type=png)](https://mermaid.live/edit#pako:eNp1kM0KwjAQhF8l7NX2BXIoCF4FwYIH42Fptj-Yn5psDlL67qYtoiDuYVmG-WB2Jmi8JpAQ6ZHINXQYsAtoRR7llr03Q0NlVe1OGGPdB5-6_oLGEEsxfqTa38nFDflxlpn_EqW4Cg7oYktB8AqK2z-0qso1ghRofXIcoQBLweKgc-xpwRRwT5YUyHxqajEZVqDcnK2Y2J-frgHJIVEBadTI7y9BtmhiVkkP7MNxq2JtZH4BzOZhcA)

### How does it forward funds?

Via a single external, pausable function taking an array of tokens to forward (0x0 for ETH).

### How is it governed?

A PassThroughWallet's owner, if set, has FULL CONTROL of the deployment. It may, at any time for any reason, change the passThrough, pause the flow, or execute arbitrary calls on behalf of the PassThroughWallet. In situations where flows ultimately belong to or benefit more than a single person & immutability is a nonstarter, we strongly recommend using multisigs or DAOs for governance.

## Lint

`forge fmt`

## Setup & test

`forge i` - install dependencies

`forge b` - compile the contracts

`forge t` - compile & test the contracts

`forge t -vvv` - produces a trace of any failing tests

## Natspec

`forge doc --serve --port 4000` - serves natspec docs at http://localhost:4000/
