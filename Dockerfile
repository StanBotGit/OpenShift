##See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.
#
#FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
FROM registry.access.redhat.com/ubi8/dotnet-31:3.1

WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM registry.access.redhat.com/ubi8/dotnet-31:3.1 AS build
WORKDIR /src
COPY ["OpenShift/OpenShift.csproj", "OpenShift/"]
RUN dotnet restore "OpenShift/OpenShift.csproj"
COPY . .
WORKDIR "/src/OpenShift"
RUN dotnet build "OpenShift.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "OpenShift.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OpenShift.dll"]