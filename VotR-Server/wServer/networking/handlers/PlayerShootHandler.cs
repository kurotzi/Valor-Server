﻿using common.resources;
using wServer.realm.entities;
using wServer.networking.packets;
using wServer.networking.packets.incoming;
using wServer.networking.packets.outgoing;
using wServer.realm;
using log4net;
using System;
using System.Collections.Generic;

namespace wServer.networking.handlers
{
    class PlayerShootHandler : PacketHandlerBase<PlayerShoot>
    {
        public override PacketId ID => PacketId.PLAYERSHOOT;
        private static readonly ILog CheatLog = LogManager.GetLogger("CheatLog");

        protected override void HandlePacket(Client client, PlayerShoot packet)
        {
            //client.Manager.Logic.AddPendingAction(t => Handle(client.Player, packet, t));
            Handle(client.Player, packet);
        }

        private int condHitReq = -1;

        private void Handle(Player player, PlayerShoot packet)
        {
            if (player?.Owner == null) return;

            Item item;
            if (!player.Manager.Resources.GameData.Items.TryGetValue(packet.ContainerType, out item))
            {
                player.DropNextRandom();
                return;
            }

            if (item == player.Inventory[1])
                return; // ability shoot handled by useitem

            // validate
            var result = player.ValidatePlayerShoot(item, packet.Time);
            if (result != PlayerShootStatus.OK)
            {
                CheatLog.Info($"PlayerShoot validation failure ({player.Name}:{player.AccountId}): {result}");
                player.DropNextRandom();
                return;
            }

            // create projectile and show other players
            var prjDesc = item.Projectiles[0]; //Assume only one

            foreach (var pair in prjDesc.CondChance) {
                if (pair.Value == 0 || pair.Key == default(ConditionEffect)) return;

                if (pair.Value / 100 > new Random().NextDouble()) {
                    var effList = new List<ConditionEffect>(prjDesc.Effects);
                    effList.Add(pair.Key);
                    prjDesc.Effects = effList.ToArray();
                }
            }

            Projectile prj = player.PlayerShootProjectile(
                packet.BulletId, prjDesc, item.ObjectType,
                packet.Time, packet.StartingPos, packet.Angle);
            player.Owner.EnterWorld(prj);
            player.Owner.BroadcastPacketNearby(new AllyShoot()
            {
                OwnerId = player.Id,
                Angle = packet.Angle,
                ContainerType = packet.ContainerType,
                BulletId = packet.BulletId
            }, player, player, PacketPriority.Low);
            player.FameCounter.Shoot(prj);
        }
    }
}
