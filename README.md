# splits-pass-through-wallet

## What

Pass-through wallet is an ownable smart contract wallet with pausable-but-otherwise-permissionless fund forwarding

## Why

Some onchain value flows require or benefit greatly from inserting full smart contract wallet functionality

## How

[![Sequence diagram of passThroughFunds](https://mermaid.ink/svg/pako:eNqNkl9LwzAUxb9KiJQ-uMFw3R_6UFjn-iYIij5YH-7a2y2YJjO5FcfYdzdtmVvnFF-ScO_vnOSSs-OZzpGH3PN2qWJMKEEha46M-bTGEv2Q-Uuw6PdOq09gBCwlWv8bb5qFVpRAKeS21tWQPAhbMX7SXEtt6vbVOJ7cTAcdYGNECWZ7ZJJhEiTjS0ysTY7mTzeLmVZ5x2-8WEziyWXq3HEQTKajLgsZiQ8godU_YEJDonP7bBQHyfwidO4XDIfT-cxvyX29uWXvealKlcX3ClWGtwJWBsqaaLmZFBn2o-j6Hqx9XBtdrdbPICW6b90cS4_6DZVtJT_IvtOfFEP2wsiAsgUaRo2Qvf4mjaJ-84SQQakrRZb3eImmBJG7lDVJSXmToJSH7phjAZWklLvRHAoV6YetynhIpsIerzY50GFKHhYgratiLkibuza5TYD3X2Yo2mk?type=png)](https://mermaid.live/edit#pako:eNqNkl9LwzAUxb9KiJQ-uMFw3R_6UFjn-iYIij5YH-7a2y2YJjO5FcfYdzdtmVvnFF-ScO_vnOSSs-OZzpGH3PN2qWJMKEEha46M-bTGEv2Q-Uuw6PdOq09gBCwlWv8bb5qFVpRAKeS21tWQPAhbMX7SXEtt6vbVOJ7cTAcdYGNECWZ7ZJJhEiTjS0ysTY7mTzeLmVZ5x2-8WEziyWXq3HEQTKajLgsZiQ8godU_YEJDonP7bBQHyfwidO4XDIfT-cxvyX29uWXvealKlcX3ClWGtwJWBsqaaLmZFBn2o-j6Hqx9XBtdrdbPICW6b90cS4_6DZVtJT_IvtOfFEP2wsiAsgUaRo2Qvf4mjaJ-84SQQakrRZb3eImmBJG7lDVJSXmToJSH7phjAZWklLvRHAoV6YetynhIpsIerzY50GFKHhYgratiLkibuza5TYD3X2Yo2mk)

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
