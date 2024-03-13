﻿FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
ENV ASPNETCORE_ENVIRONMENT Development
RUN mkdir /repo && chown $APP_UID /repo
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ENV ASPNETCORE_ENVIRONMENT Development
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["SS14.Admin/SS14.Admin.csproj", "SS14.Admin/"]
RUN dotnet restore "SS14.Admin/SS14.Admin.csproj"
COPY . .
WORKDIR "/src/SS14.Admin"
RUN dotnet build "SS14.Admin.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ENV ASPNETCORE_ENVIRONMENT Development
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "SS14.Admin.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
ENV ASPNETCORE_ENVIRONMENT Development
WORKDIR /app
COPY --from=publish /app/publish .
VOLUME ["/app"]
ENTRYPOINT ["dotnet", "SS14.Admin.dll", "--environment=Development"]
