{config, lib, pkgs, ...}:

let
  container_name = "postfix-relay";
  container_description = "Enables SMTP message relay container";
  container_image_registry = "docker.io";
  container_image_name = "tiredofit/postfix";
  container_image_tag = "latest";
  cfg = config.host.container.${container_name};
  hostname = config.host.network.hostname;
  activationScript = "system.activationScripts.docker_${container_name}";
in
  with lib;
{
  options = {
    host.container.${container_name} = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = container_description;
      };
      image = {
        name = mkOption {
          default = container_image_name;
          type = with types; str;
          description = "Image name";
        };
        tag = mkOption {
          default = container_image_tag;
          type = with types; str;
          description = "Image tag";
        };
        registry = {
          host = mkOption {
            default = container_image_registry;
            type = with types; str;
            description = "Image Registry";
          };
        };
      };
      logship = mkOption {
        default = "false";
        type = with types; str;
        description = "Enable monitoring for this container";
      };
      monitor = mkOption {
        default = "false";
        type = with types; str;
        description = "Enable monitoring for this container";
      };
    };
  };

  config = mkIf cfg.enable {
    system.activationScripts."docker_${container_name}" = ''
      if [ ! -d /var/local/data/_system/${container_name}/logs ]; then
          mkdir -p /var/local/data/_system/${container_name}/logs
          ${pkgs.e2fsprogs}/bin/chattr +C /var/local/data/_system/${container_name}/logs
      fi

      ## This one stores its databases as the same filename so lets disable CoW
      if [ ! -d /var/local/data/_system/${container_name}/data ]; then
          mkdir -p /var/local/data/_system/${container_name}/data
          ${pkgs.e2fsprogs}/bin/chattr +C /var/local/data/_system/${container_name}/data
      fi
    '';

    systemd.services."docker-${container_name}" = {
      serviceConfig = {
        StandardOutput = "null";
        StandardError = "null";
      };
    };

    virtualisation.oci-containers.containers."${container_name}" = {
      image = "${cfg.image.name}:${cfg.image.tag}";
      ports: = [
        "127.0.0.1:25:25"
      ];
      volumes = [
        "/var/local/data/_system/${container_name}/logs:/data"
        "/var/local/data/_system/${container_name}/logs:/logs"
      ];
      environment = {
      "TIMEZONE" = "America/Vancouver";
      "CONTAINER_NAME" = "${hostname}-${container_name}";
      "CONTAINER_ENABLE_MONITORING" = cfg.monitor;
      "CONTAINER_ENABLE_LOGSHIPPING" = cfg.logship;

      "MODE" = "RELAY";
      "RELAY_HOST" = "common_env";
      "RELAY_PORT" = "25";
      "RELAY_USER"= "host_env";
      "RELAY_PASS"= "host_env";
      "SERVER_NAME" = "${hostname}.${config.host.network.domainname}";
      "ACCEPTED_NETWORKS" = "172.16.0.0/12";
      };
      environmentFiles = [

      ];
      extraOptions = [
        "--memory=256M"
        "--network=services"
        "--network-alias=${hostname}-${container_name}"
      ];

      autoStart = mkDefault true;
      log-driver = mkDefault "local";
      login = {
        registry = cfg.image.registry.host;
      };
    };
  };
}