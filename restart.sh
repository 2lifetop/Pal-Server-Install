#!/bin/bash
docker restart steamcmd
docker exec -d steamcmd /bin/bash -c "/home/steam/Steam/steamapps/common/PalServer/PalServer.sh"
