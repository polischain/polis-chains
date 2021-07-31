FROM mcr.microsoft.com/dotnet/sdk:5.0-focal AS build

RUN apt-get update && \
    apt-get install -y libsnappy-dev libc6-dev libc6

RUN git clone https://github.com/NethermindEth/nethermind --recursive

WORKDIR /nethermind

COPY specs/* src/Nethermind/Chains
COPY configs/sparta/* src/Nethermind/Nethermind.Runner/configs
#COPY configs/athene/* src/Nethermind/Nethermind.Runner/configs

RUN dotnet publish src/Nethermind/Nethermind.Runner -r linux-x64 -c release -o out

FROM mcr.microsoft.com/dotnet/sdk:5.0-focal

RUN apt-get update && apt-get -y install libsnappy-dev libc6-dev libc6

WORKDIR /nethermind

COPY --from=build /nethermind/out .

EXPOSE 30303
EXPOSE 8545

VOLUME /nethermind/nethermind_db
VOLUME /nethermind/logs
VOLUME /nethermind/keystore

ENTRYPOINT ["./Nethermind.Runner"]