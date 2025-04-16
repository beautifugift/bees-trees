# Bees & Trees Land Registry Smart Contract

A Clarity smart contract for registering and managing land plots with environmental data tracking capabilities.

## Overview

The Bees & Trees Land Registry is a blockchain-based system built on Clarity and the Stacks blockchain that enables:

- Registration of land plots with unique identifiers
- Tracking of ownership and transfers
- Storage of plot metadata (location, size, tree count)
- Environmental impact monitoring through tree count tracking

This decentralized land registry provides transparency, security, and immutability for land records while supporting environmental conservation efforts.

## Features

- **Plot Registration**: Register new plots with location data, size, and tree count
- **Ownership Management**: Transfer plot ownership securely between addresses
- **Metadata Updates**: Update plot information and environmental metrics
- **Tree Count Tracking**: Specifically track reforestation efforts with dedicated tree count updates
- **Data Queries**: Retrieve plot information and statistics

## Smart Contract Functions

### Public Functions (Write Operations)

| Function | Description | Parameters |
|----------|-------------|------------|
| `register-plot` | Register a new plot of land | `plot-id`: unique identifier<br>`location`: GPS coordinates<br>`size`: plot size<br>`tree-count`: number of trees |
| `transfer-plot` | Transfer ownership to another address | `plot-id`: plot identifier<br>`new-owner`: recipient address |
| `update-plot-data` | Update all plot metadata | `plot-id`: plot identifier<br>`location`: GPS coordinates<br>`size`: plot size<br>`tree-count`: number of trees |
| `update-tree-count` | Update only the tree count | `plot-id`: plot identifier<br>`new-tree-count`: updated tree count |

### Read-Only Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `get-plot-info` | Retrieve plot information | `plot-id`: plot identifier |
| `get-total-plots` | Get total number of registered plots | None |

## Error Codes

| Code | Description |
|------|-------------|
| `ERR-NOT-AUTHORIZED` (u1) | Caller is not the plot owner |
| `ERR-PLOT-EXISTS` (u2) | Plot ID already registered |
| `ERR-PLOT-NOT-FOUND` (u3) | Plot ID does not exist |

## Usage Examples

### Registering a New Plot

```clarity
;; Register a 5000 sq meter plot with 120 trees
(contract-call? .bees-and-trees-registry register-plot u1 "37.7749,-122.4194" u5000 u120)
