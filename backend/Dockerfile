FROM archlinux:latest

# Update system and install base dependencies
RUN pacman -Syu --noconfirm \
    base-devel \
    git \
    ffmpeg \
    poco \
    zlib \
    opencl-headers \
    python \
    python-pip

# Create a non-root user for AUR builds
RUN useradd -m builder
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
WORKDIR /home/builder

# Install yay (AUR helper)
RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm

# Install sanjuuni from AUR
RUN yay -S --noconfirm sanjuuni

# Switch back to root for Python environment + app
USER root
WORKDIR /app

# Create a virtual environment to avoid PEP 668 issues
RUN python -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

COPY . /app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
