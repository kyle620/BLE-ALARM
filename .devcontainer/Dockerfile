FROM ubuntu:latest

# Update package list and install required tools and libraries
# Note: libc6-i386 is included to ensure compatibility with 32-bit applications,  TI-RTOS installer is a 32-bit application
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    cmake \
    gcc-arm-none-eabi \
    git \
    libc6-i386 \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and run the TI-RTOS installer
RUN wget https://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/tirtos/2_21_01_08/exports/tirtos_cc13xx_cc26xx_setuplinux_2_21_01_08.bin \
    -O /tmp/tirtos_installer.bin && \
    chmod +x /tmp/tirtos_installer.bin && \
    /tmp/tirtos_installer.bin --mode unattended --prefix /opt/tirtos && \
    rm /tmp/tirtos_installer.bin

# Add XDC tools to PATH (adjust the path based on where installer puts it)
ENV PATH="/opt/tirtos/xdctools_3_32_00_06_core:${PATH}"

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
