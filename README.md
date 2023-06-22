# Welcome to the Polkanalyzer App

The Polkanalyzer app is a tool that allows one to easily visualize [Polkadot](https://polkadot.network/)'s NPoS data and make a fair selection of validator nodes. It is a [staking](https://wiki.polkadot.network/docs/learn-staking) tool for [nominators](https://wiki.polkadot.network/docs/learn-nominator) and [nomination pools admins](https://wiki.polkadot.network/docs/learn-nomination-pools).

## Problem

Although Polkadot is highly decentralized compared to other networks, decentralization can be improved to favor smaller validator nodes that struggle to enter the active set. Nominators want to maximize staking rewards by avoiding having days with no payouts. This leads to nominations of validators that are active all the time and that are owned by big operators. Such nodes have lower commissions, are big operators that centralize resources, and can afford to validate at lower costs. This leads to a positive feedback loop where the increased nomination of those operators' nodes will lead to those operators accumulating enough resources to open new active validator nodes. See the [Polkawatch app](https://polkawatch.app/validation) for more insights.

The [One Thousand Validator Program](https://wiki.polkadot.network/docs/thousand-validators) (1KV Program) focuses on incentivizing people to set up nodes by helping them get to the active set using a stash account owned by the [Web3 Foundation](https://web3.foundation/). However, going online a few times per month could be insufficient to cover the costs and time running those nodes and ensuring those nodes run safely (especially in unfavorable economic conditions). This leads to 1KV nodes being inactive most of the time, leaving their nominators with no rewards and possibly changing nominations.

## Solution

Here I propose this simple tool that allows nominating validators from the 1KV program through a [stratified synchronization algorithm](#stratified-synchronisation) that maximizes daily rewards with no big operators in the nomination. This makes the nomination healthier for the ecosystem as it decentralizes selection and helps 1KV nodes get organic nominations and build their reputation. The selection is purely objective and provides a quick and solid alternative to selecting the validators by purely looking at the commission or total stake.

## Installation

- Install [docker](https://docs.docker.com/desktop/install/mac-install/) on your machine
- Download the [polkanalyzer-app folder](https://github.com/filippoweb3/polkanalyzer-app/archive/refs/heads/main.zip)
- Open the terminal, navigate to the app folder and run the followings commands:
  - `docker build -t polkanalyzer-app .` (this will take some time)
  - `docker run --rm -p 127.0.0.1:3838:3838 -it polkanalyzer-app:latest`
  - Go to `127.0.0.1:3838` in your browser
  
## What you can do

### Preliminary Selection

On the app’s top are sliders, drop-down menus, and checkboxes to make a preliminary selection of the validators based on nominator preferences. See below a list of selection criteria and a short explanation for each.

- Past Eras: Number of eras to look back from the present time (restricted to a maximum of 60 eras).
- Eras Active: Number of eras the validators were active in the Past Eras.
- Self Stake: Stake that an operator has on a specific validator node.
- Total Stake: The total stake of a validator (i.e., Self Stake + stake coming from nominators).
- Commission: The commission charged by the validator.
- Avg. Era Points: Average [era points](https://wiki.polkadot.network/docs/learn-staking#selection-of-validators) across the Past Eras.
- Max Era Points: Maximum era points reached within the Past Eras.
- Faulty Events: Number of faulty events in the validator’s lifetime.
- Offline Events: Number of offline events in the validator’s lifetime.
- Sub-identities: Number of [sub-identities](https://wiki.polkadot.network/docs/learn-identity#sub-accounts) of an operator.
- Sync Runs: Number of [synchronization runs](#stratified-synchronisation). Increasing the number of runs will lead to higher loading times as the app has to perform multiple synchronizations.
- Exclude Provider: Possibility to exclude [cloud service providers](https://wiki.polkadot.network/docs/learn-staking#network-providers). Note that the number after the `#` shows the number of active validators using the provider in the last available era. Providers are ordered in descending order from the most to the least popular.
- Exclude country: Possibility to exclude countries where nodes are located.
- Exclude continent: Possibility to exclude continents where nodes are located.
- Verified Identity: Choose whether the validator has a verified [identity](https://wiki.polkadot.network/docs/learn-identity). Recommended to leave this check box checked.

### World Map

Locations of synchronized validators. The user can inspect the node name, self stake, city, and country by hovering over each location.

### Matrix Plot

Era points, self stake commission, and total stake. This information is similar to that displayed by the [Polkadot-JS UI](https://polkadot.js.org/apps/#/staking/query), but since data are pre-loaded, the inspection should be less time-consuming on Polkanalyzer.

### Selection Table

The selection table shows the selected synchronized validators within each synchronization run. By clicking each row, the user can see valuable metrics for that validator in the [Matrix Plot](#matrix-plot) and the node location in the [World Map](#world-map).

## Stratified Synchronisation

After the preliminary selection filtered out all validators that do not fit in the chosen selection criteria, we want to make sure that we can cover as many past eras as possible to maximize the chance we can get daily rewards in future eras without using big nodes that are active all the time.

This is achieved through a stratified synchronization that selects validators prioritizing past era coverage. For example, if we select **Past Eras = 30** and **Eras Active = 10**, we will consider only those nodes active for a maximum of 10 eras in the past 30 eras. The synchronization algorithm picks up nodes to fill all past 30 eras; when the era coverage reaches 100%, it starts, again and again, depending on how many **Sync Runs** the user wants to perform (given there are enough validators to perform those runs). If multiple nodes are selected to cover specific eras, the one with the highest self stake is prioritized (as this is the node having the most to lose in case of a [slash](https://wiki.polkadot.network/docs/maintain-guides-validator-payout#slashing)). The results are multiple runs, each including synchronized validators covering 100% of the past 30 eras and together covering the past 30 eras multiple times (i.e., stratified synchronization). Note that the last run might not cover 100% of the past eras.

