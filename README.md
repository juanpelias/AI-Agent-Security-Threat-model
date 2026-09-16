# AI Agent Security Threat Model
## Task 1.1: VM Installation

1. **Provision the VM**: 
   Use an Ubuntu 24.04 LTS x86-64 VM. You can download a [pre-built image](https://www.linuxvmimages.com/images/ubuntu-2404/) or install from the [official ISO](https://releases.ubuntu.com/24.04/).
   * **Minimum Specs**: 4 vCPUs and 8GB RAM.
   * **Network**: The VM must use a private NAT address and default route through the virtualization platform (do NOT expose directly to the campus/home LAN).

2. **Verify Architecture and Network**:
   Open a terminal in the VM and run:
   ```bash
   uname -m          # Expected output: x86_64
   ip -brief address # Verify private NAT IP
   ip route          # Verify default route
Task 1.2: Base OS Packages
Update the system and install required baseline tools:

Bash
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y curl git
(Note: Run sudo reboot if the full-upgrade pulled a new kernel).

Task 1.3: Node.js and OpenClaw Installation
Install Node.js version 24 LTS via nvm, followed by the exact required version of OpenClaw. Do not use openclaw@latest.

Bash
# Install nvm and source it
curl -o- [https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh](https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh) | bash
source "$HOME/.nvm/nvm.sh"

# Install and set default Node version
nvm install 24.18.0
nvm alias default 24.18.0

# Verify Node installation
node --version
npm --version

# Install exact OpenClaw version
npm install -g openclaw@2026.7.1-2
openclaw --version
Task 1.4: Model Setup and Connect to OpenClaw
This lab uses the TAMUS AI API (e.g., protected.gpt-4o). To bypass HTTP 422 errors caused by OpenClaw's OpenAI compatibility layer, you must run the provided local shim (tamu-shim.mjs).

Start the Compatibility Shim:
Open a dedicated terminal window and leave this running:

Bash
export TAMU_API_KEY="your_api_key_here"
node tamu-shim.mjs
(The shim will listen on http://127.0.0.1:8899)

Onboard OpenClaw:
In a new terminal window, execute the following configuration commands:

Bash
# Onboard the custom provider via the local shim
openclaw onboard --non-interactive --accept-risk \
  --auth-choice custom-api-key \
  --custom-provider-id tamus \
  --custom-compatibility openai \
  --custom-base-url "[http://127.0.0.1:8899/openai](http://127.0.0.1:8899/openai)" \
  --custom-api-key via-shim \
  --custom-model-id "protected.gpt-4o" \
  --skipchannels

# Configure OpenClaw settings
openclaw config set models.providers.tamus.request.allowPrivateNetwork true
openclaw config set agents.defaults.timeoutSeconds 600
openclaw config set agents.defaults.memorySearch.enabled false
openclaw config validate

# Set default model and start daemon
openclaw models set tamus/protected.gpt-4o
openclaw daemon install && openclaw daemon start
Task 1.5: Verify Lab Setup
Finally, verify the agent connection, configuration, and execution policies.

Bash
# Check runtime status
openclaw gateway status 

# Ensure there are no blocking errors
openclaw doctor 

# Review execution policies (Needed for Tasks 3 & 4)
openclaw exec-policy show 

# Run a test inference to verify model connectivity
openclaw infer model run --model tamus/protected.gpt-4o \
  --prompt "Reply with exactly: agent-ready"
