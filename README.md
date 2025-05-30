# Dynamic NFC Route Protection

This project built with a canister on the ICP (Internet Computer Protocol) implements a system for protecting web routes using the NFC tags NTAG 424 DNA. 
Afer canister deployment it allows to dynamically protects specific web pages URLs by requiring NTAG 424 DNA tag authentication. What makes this solution unique is that it can be seamlessly integrated into any existing canister to secure specific routes. Anyone with a D-Logic uFR or uFR ZERO series reader/writer and NTAG 424 tags can easily implement this protection system with very few modifications to their application.

## Overview

This repo consists of :

- A motoko canister that act at the same time as a backend service that validates NFC authentication and serves web content.
- Python scripts to program NTAG424 NFC tags and configure protected routes on the deployed canister
- Simple web pages to demonstrate the concept
- reader script with Node.js to test the system locally

## Prerequisites

- **DFINITY SDK (dfx)** - [Installation Guide](https://internetcomputer.org/docs/building-apps/getting-started/install)

    ```sh
    # Node.js is required
    sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
    ```
- **Python 3** with the required packages:
  - `pycrypto`
  - `ctypes`

- **Rust Toolchain & icx-asset**
  
  If Rust is not installed, install it using [rustup](https://rustup.rs/) :
  
  ```sh
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source $HOME/.cargo/env
  ```
  
  Then, install `icx-asset`:
  
  ```sh
  cargo install icx-asset
  ```

- **A D-Logic NFC card reader/writer** 

Only works with D-Logic uFR and uFR ZERO series reader/writer : [Available here](https://www.d-logic.com/)

The appropriate drivers needs to be installed :
[D-Logic code repository](https://code.d-logic.com/-/snippets/1)

- **One empty NTAG424 DNA NFC tag for each URL to be protected**

## Setup

1. **Clone this repo**

   ```sh
   git clone git@github.com:Inuani/dynamic_route_nfc_protection.git dynamic-nfc-route-protec
   cd dynamic-nfc-route-protec
   ```

2. **Set up your Python environment**

   ```sh
   python3 -m venv venv
   source venv/bin/activate
   pip3 install pycrypto ctypes
   ```

3. **Deploy the Motoko Canister and upload the assets locally**

Before you begin, update the Makefile to use your identity:
- locate the `upload_assets` target
- Change the path from `~/.config/dfx/identity/raygen/identity.pem` to your identity's pem file path. More doc on dfx identity and pemfile [here](https://internetcomputer.org/docs/building-apps/getting-started/identities)

Then deploy with:

```sh
# Start the local IC replica
dfx start --background

# Deploy the canister
make

# Upload frontend assets inside the deployed canister
make upload_assets
```

5. **Program NFC Cards**

Connect the D-Logic NFC reader/writer to your computer.
Place an empty NTAG 424 NFC tag on the device.
Choose one of the following commands:

```sh
# Protect page1.html with default key
make protect_route_example

# Protect page1.html with a randomly generated key (more secure)
make random_key

# For deploying to the IC mainnet instead of local replica
make production_ic
```

## Understanding Route Protection Creation

```sh
python3 scripts/setup_route.py <canister_id> <page_path> [--random-key] [--params "key=value"] [--ic]
```
Arguments:

<canister_id> (required): The unique identifier for your deployed canister (e.g., "br5f7-7uaaa-aaaaa-qaaca-cai")

<page_path> (required): The web page you want to protect (e.g., "page1.html")

Optional Flags:

--random-key: Generates a unique cryptographic key for the NFC tag instead of using the default zero key. Recommended for production use to increase security. WARNING: this can not be undone!

--params "key=value": Adds custom query parameters to the protected URL. These parameters will be included in the URL when the NFC tag is read.

--ic: Configures the tag for the IC mainnet instead of a local replica. Use this flag when deploying to production.

## Testing a Protected Route:

After programming the NFC tag, you can verify the protection works.

Try accessing the protected URL directly in your browser
You should be redirected to the "Invalid scan" page

Then place the programmed tag on the NFC reader
Run the reader software:

```sh
cd reader
node simple_reader.js
```

The browser will automatically open with a special authenticated URL. The canister will validate the dynamic URL signature and if valid the protected content will display instead of the invalid scan page.

## Live Example

Here is a working implementation that is build on this single backend & asset webserver
canister that demonstrates how physical products can be connected to digital assets using NFC protection:

https://75y2r-piaaa-aaaak-qt2tq-cai.raw.icp0.io/

This application connects a physical hoodie to its digital twins canister counterpart.
The hoodie contains 10 embedded NFC tags, each linked to a different music track when scanned.

The system implements a gamification aspect:

The hoodie gains experience points when tags are scanned
Additional XP is earned when new songs are uploaded
While the song URLs can be accessed directly, only NFC tag scans contribute to the hoodie's experience

For more photos of the physical hoodie, visit my instagram [here](https://www.instagram.com/p/DGToEDcuppf/)

<img src="src/example.png" alt="web page hoodie" width="700" />

<img src="src/example2.jpg" alt="rap hoodie phone" width="700" />

## License

This project is licensed under the MIT License.