# splits-pass-through-wallet

## What

Pass-through wallet is an ownable smart contract wallet with pausable-but-otherwise-permissionless fund forwarding

## Why

Some onchain value flows require or benefit greatly from inserting full smart contract wallet functionality

## How

[![Sequence diagram of passThroughFunds](https://mermaid.ink/img/pako:eNp1kk1LAzEQhv9KiCx7sHtTCzkstLW9CYJFD66H6Wa2DeajTpJDKf3vZrPUdlETSIZ3njckmTny1knkghfFsbGMKauCYDlkrAw7NFgKVm7AYzm5Vl-BFGw0-vIHz8nO2bACo_Sh9_WQPhtzfk_KAB0WTjvqiZvVrJ9_MXNHEulCLvIYkR5bZ-XovIflcjqfjqiAFNQImt3P71aLcmBO_ZaWU1E0trEevyLaFh8VbAlMTwzcTKsWq7q-fQbv1ztycbt7A60x_dj-Iq3dJ1o_WH6RVfJfiYK9s0BgfYfEQjayj_-sdV3lKwgGxkUbPJ9wg2RAyVTAXISG5-I0XKRQYgdRh4anpyUUYnAvB9tyESjihMe9hHB-JRcdaJ9UlCo4ehqaIvfG6RtP0602?type=png)](https://mermaid.live/edit#pako:eNp1kk1LAzEQhv9KiCx7sHtTCzkstLW9CYJFD66H6Wa2DeajTpJDKf3vZrPUdlETSIZ3njckmTny1knkghfFsbGMKauCYDlkrAw7NFgKVm7AYzm5Vl-BFGw0-vIHz8nO2bACo_Sh9_WQPhtzfk_KAB0WTjvqiZvVrJ9_MXNHEulCLvIYkR5bZ-XovIflcjqfjqiAFNQImt3P71aLcmBO_ZaWU1E0trEevyLaFh8VbAlMTwzcTKsWq7q-fQbv1ztycbt7A60x_dj-Iq3dJ1o_WH6RVfJfiYK9s0BgfYfEQjayj_-sdV3lKwgGxkUbPJ9wg2RAyVTAXISG5-I0XKRQYgdRh4anpyUUYnAvB9tyESjihMe9hHB-JRcdaJ9UlCo4ehqaIvfG6RtP0602)

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
