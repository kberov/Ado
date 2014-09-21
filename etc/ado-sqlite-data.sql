/**
 Careful developers will not make any assumptions about whether or not
 foreign keys are enabled by default but will instead enable or disable
 them as necessary.
 http://www.sqlite.org/foreignkeys.html#fk_enable
 We do this only for the initial data.
 Further on we will always have 'PRAGMA foreign_keys = ON;'
*/
PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

INSERT INTO `domains` 
VALUES(1,'localhost','LocalHost',
'Localhost - used only for testing purposes',1,1,'-rwxr-xr-x',1);

INSERT INTO `groups` VALUES(0,'null','null group',1,1,1);
INSERT INTO `users` VALUES(0,0,'null','9f1bd12057905cf4f61a14e3eeac06bf68a28e64',
'Null','Null','null@localhost',
'System user. Do not use!',
1,1,54022241011303270,0,1,1,1);

INSERT INTO `groups` VALUES(1,'admin','admin',1,1,0);
INSERT INTO `users` VALUES(1,1,'foo','9f1bd12057905cf4f61a14e3eeac06bf68a28e64',
'Foo','Bar','foo@localhost',
'System user. Do not use!',
1,1,54022241011303270,0,1,0,0);
INSERT INTO `user_group` VALUES(1,1);

INSERT INTO `groups` VALUES(2,'guest','guest',1,1,0);
INSERT INTO `users` VALUES(2,2,'guest','8097beb8d5950479e49d803e683932150f469827',
'Guest','','foo@localhost',
'Guest user. Anybody not authenticated gets a guest session.',
1,1,54022241011303270,0,1,0,0);
INSERT INTO `user_group` VALUES(2,2);

INSERT INTO `groups` VALUES(3,'test1','test1',1,1,0);
INSERT INTO `users` VALUES(3,3,'test1','b5e9c9ab4f777c191bc847e1aca222d6836714b7',
'Test','1','test1@localhost',
'test1 user. Do not delete. used for tests only.',
1,1,54022241011303270,0,0,0,0);
INSERT INTO `user_group` VALUES(3,3);

INSERT INTO `groups` VALUES(4,'test2','test2',1,1,0);
INSERT INTO `users` VALUES(4,4,'test2','272a11a0206b949355be4b0bda9a8918609f1ac6',
'Test','2','test2@localhost',
'test2 user. Do not delete. Used for tests only.',
1,1,54022241011303270,0,0,0,0);
INSERT INTO `user_group` VALUES(4,4);

COMMIT;

PRAGMA foreign_keys = ON;
VACUUM;
