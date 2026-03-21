FROM oven/bun:1

# 1. Install Chromium, Xvfb, and required system libraries for rendering
RUN apt-get update && apt-get install -y --fix-missing \
    wget \
    gnupg \
    ca-certificates \
    apt-transport-https \
    chromium \
    chromium-driver \
    xvfb \
    libnss3 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libgbm1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# 2. Set environment variables for Hugging Face and Chromium
ENV CHROME_BIN=/usr/bin/chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PORT=7860
ENV NODE_ENV=production

# 3. Create a non-root user with UID 1000 (Mandatory for Hugging Face)
RUN useradd -m -u 1000 user
WORKDIR /home/user/app

# 4. Copy package files and install dependencies as the 'user'
COPY --chown=user:user package*.json ./
RUN bun install

# 5. Copy the rest of the application code
COPY --chown=user:user . .

# 6. Switch to the non-root user
USER user

# 7. Inform Hugging Face which port to route traffic to
EXPOSE 7860

# 8. Start the app using xvfb-run to provide a virtual display
# This allows your code's 'headless: false' setting to work on a server
CMD ["bun", "run", "start"]
