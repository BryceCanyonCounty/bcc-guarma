INSERT INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`) VALUES ('boat_ticket', 'Boat Ticket', 20, 1, 'item_standard', 1, 'Saint Denis-Guarma Express')
    ON DUPLICATE KEY UPDATE `item`='boat_ticket', `label`='Boat Ticket', `limit`=20, `can_remove`=1, `type`='item_standard', `usable`=1, `desc`='Saint Denis-Guarma Express';
