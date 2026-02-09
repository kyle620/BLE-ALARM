FROM ubuntu:latest

# Update package list and install required tools and libraries
# Note: libc6-i386 is included to ensure compatibility with 32-bit applications,  TI-RTOS installer is a 32-bit application
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    cmake \
    git \
    libc6-i386 \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and run the TI-RTOS installer, this installs both TI-RTOS and the XDC tools
RUN wget https://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/tirtos/2_21_01_08/exports/tirtos_cc13xx_cc26xx_setuplinux_2_21_01_08.bin \
    -O /tmp/tirtos_installer.bin && \
    chmod +x /tmp/tirtos_installer.bin && \
    /tmp/tirtos_installer.bin --mode unattended --prefix /opt/tools/tirtos && \
    rm /tmp/tirtos_installer.bin

    # Add XDC tools to PATH
ENV PATH="/opt/tools/tirtos/xdctools_3_32_00_06_core:${PATH}"

# Download and intall the TI Compiler for ARM (ti_cgt) which is required for building TI-RTOS applications for CC2650
RUN wget https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-sDOoXkUcde/20.2.6.LTS/ti_cgt_tms470_20.2.6.LTS_linux-x64_installer.bin \
    -O /tmp/ti_cgt_installer.bin && \
    chmod +x /tmp/ti_cgt_installer.bin && \
    /tmp/ti_cgt_installer.bin --mode unattended --prefix /opt/tools/compiler && \
    rm /tmp/ti_cgt_installer.bin

# Add TI Compiler ti_cgt to PATH (adjust the path based on where installer puts it)
ENV PATH="/opt/tools/compiler/ti-cgt-arm_20.2.6.LTS/bin:${PATH}"

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
