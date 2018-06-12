FROM ubuntu:17.10

ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK /opt/android-sdk-linux

ENV PATH "${PATH}:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/bin"

ENV DEBIAN_FRONTEND noninteractive

# Install required tools
# Dependencies to execute Android builds

RUN dpkg --add-architecture i386 && apt-get update -yqq && apt-get install -y \
  bzip2 \
  curl \
  expect \
  git \
  libc6:i386 \
  libgcc1:i386 \
  libncurses5:i386 \
  libstdc++6:i386 \
  net-tools \
  openjdk-8-jdk \
  openssh-server \
  socat \
  software-properties-common \
  ssh \
  unzip \
  vim \
  wget \
  zlib1g:i386 \
  && apt-get clean

RUN groupadd android && useradd -d /opt/android-sdk-linux -g android android

COPY tools /opt/tools

COPY licenses /opt/licenses

WORKDIR /opt/android-sdk-linux

RUN /opt/tools/entrypoint.sh built-in

RUN /opt/android-sdk-linux/tools/bin/sdkmanager "build-tools;27.0.3"

RUN /opt/android-sdk-linux/tools/bin/sdkmanager "platforms;android-26"

RUN /opt/android-sdk-linux/tools/bin/sdkmanager "system-images;android-26;google_apis;x86_64"

# CMD /opt/tools/entrypoint.sh built-in

# ENTRYPOINT [ "executable" ]

# ADD entrypoint.sh /tools/entrypoint.sh

# RUN chmod +x /tools/entrypoint.sh

ENTRYPOINT ["/opt/tools/entrypoint.sh", "built-in", "launch_emulator"]
