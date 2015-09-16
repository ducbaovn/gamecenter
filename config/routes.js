/**
 * Route Mappings
 * (sails.config.routes)
 *
 * Your routes map URLs to views and controllers.
 *
 * If Sails receives a URL that doesn't match any of the routes below,
 * it will check for matching files (images, scripts, stylesheets, etc.)
 * in your assets directory.  e.g. `http://localhost:1337/images/foo.jpg`
 * might match an image file: `/assets/images/foo.jpg`
 *
 * Finally, if those don't match either, the default 404 handler is triggered.
 * See `api/responses/notFound.js` to adjust your app's 404 logic.
 *
 * Note: Sails doesn't ACTUALLY serve stuff from `assets`-- the default Gruntfile in Sails copies
 * flat files from `assets` to `.tmp/public`.  This allows you to do things like compile LESS or
 * CoffeeScript for the front-end.
 *
 * For more information on configuring custom routes, check out:
 * http://sailsjs.org/#/documentation/concepts/Routes/RouteTargetSyntax.html
 */

module.exports.routes = {

  /***************************************************************************
  *                                                                          *
  * Make the view located at `views/homepage.ejs` (or `views/homepage.jade`, *
  * etc. depending on your default view engine) your home page.              *
  *                                                                          *
  * (Alternatively, remove this and add an `index.html` file in your         *
  * `assets` directory)                                                      *
  *                                                                          *
  ***************************************************************************/

  '/': {
    view: '500'
  },

  /**********************************************************
  * SMART API                                               *
  **********************************************************/

  // common config  
  'post /v1/smart/config': 'smart/Smart_ConfigurationController.getConfiguration',

  // image list
  'post /v1/smart/image/list': 'smart/Smart_ImageController.list', 
  
  // authenticate api
  'post /v1/smart/auth/register': 'smart/Smart_AuthController.register',
  'post /v1/smart/auth/registerfb': 'smart/Smart_AuthController.registerFb',
  'post /v1/smart/auth/registergg': 'smart/Smart_AuthController.registerGg',
  'post /v1/smart/auth/loginfb': 'smart/Smart_AuthController.loginFb',
  'post /v1/smart/auth/logingg': 'smart/Smart_AuthController.loginGg',
  'post /v1/smart/auth/login': 'smart/Smart_AuthController.loginDb',
  'post /v1/smart/auth/logout': 'smart/Smart_AuthController.logOut',

  // user account
  'post /v1/smart/user/me': 'smart/Smart_UserController.me',
  'post /v1/smart/user/changeruby': 'smart/Smart_UserController.rubyToStars',
  'post /v1/smart/user/profile': 'smart/Smart_UserController.getProfile',
  'post /v1/smart/user/search': 'smart/Smart_UserController.search',
  'post /v1/smart/user/updateavatar': 'smart/Smart_UserController.updateAvatar',
  'post /v1/smart/user/updatenickname': 'smart/Smart_UserController.updateNickName',

  // game
  'post /v1/smart/gamecategory/list': 'smart/Smart_GameCategoryController.list',
  'post /v1/smart/game/list': 'smart/Smart_GameController.list',
 
  // notification
  'post /v1/smart/notification/list': 'smart/Smart_NotificationController.listNotification',
  'post /v1/smart/notification/create': 'smart/Smart_NotificationController.createNotification',
  'post /v1/smart/notification/read': 'smart/Smart_NotificationController.readNotification',
  'post /v1/smart/notification/remove': 'smart/Smart_NotificationController.removeNotification',
  'post /v1/smart/notification/configs': 'smart/Smart_NotificationController.getConfigList',
  'post /v1/smart/notification/setconfig': 'smart/Smart_NotificationController.setConfig',

  // friend
  'post /v1/smart/friend/add': 'smart/Smart_FriendshipController.addFriend',
  'post /v1/smart/friend/accept': 'smart/Smart_FriendshipController.acceptFriend',
  'post /v1/smart/friend/donate': 'web/Web_DonationController.gcTransferStarsToFriend',

  // exchange
  'post /v1/smart/exchange/item/list': 'smart/Smart_ExchangeController.listItems',
  'post /v1/smart/store/item/list': 'smart/Smart_ExchangeController.listItemStore',
  'post /v1/smart/exchange/category/list': 'admin/Admin_StoreCategoryController.list',

  // score
  'post /v1/smart/score/add': 'smart/Smart_ScoreController.add',
  'post /v1/smart/score/remove': 'smart/Smart_ScoreController.remove',
  'post /v1/smart/score/me': 'smart/Smart_ScoreController.me',

  // challenge 
  'post /v1/smart/challenge/add': 'smart/Smart_ChallengeController.add',
  'post /v1/smart/challenge/remove': 'smart/Smart_ChallengeController.remove',
  'post /v1/smart/challenge/me': 'smart/Smart_ChallengeController.myChallenges',
  'post /v1/smart/challenge/friendlist': 'smart/Smart_ChallengeController.friendList',
  'post /v1/smart/challenge/worldlist': 'smart/Smart_ChallengeController.worldList',
  'post /v1/smart/challenge/matchresult': 'smart/Smart_ChallengeController.matchResult',

  // leaderboard
  'post /v1/smart/leaderboard/online': 'smart/Smart_LeaderboardController.online',

  // bucket
  'post /v1/smart/bucket/me': 'smart/Smart_BucketController.getMyBucket',

  /**********************************************************
  * CHAT API                                                *
  **********************************************************/

  // peer chat
  'post /v1/smart/chat/auth': 'chat/Chat_ChatController.auth',
  'post /v1/smart/chat/onlines': 'chat/Chat_ChatController.onlines',
  'post /v1/smart/chat/private': 'chat/Chat_ChatController.peerChat',
  'post /v1/smart/chat/messages': 'chat/Chat_ChatController.messages',

  // room chat
  'post /v1/smart/chat/rooms': 'chat/Chat_RoomController.rooms',
  'post /v1/smart/room/:roomid/join': 'chat/Chat_RoomController.join',
  'post /v1/smart/room/:roomid/leave': 'chat/Chat_RoomController.leave',
  'post /v1/smart/room/:roomid/chat': 'chat/Chat_RoomController.chat',
  'post /v1/smart/room/:roomid/onlines': 'chat/Chat_RoomController.onlines',
  'post /v1/smart/room/:roomid/messages': 'chat/Chat_RoomController.messages',

  /**********************************************************
  * MATH API                                                *
  **********************************************************/

  // math single mode 
  'post /v1/math/myinfo': 'math/Math_MathController.getMyInfo',
  'post /v1/math/score': 'math/Math_MathController.postMyScore',
  'post /v1/math/myscore': 'math/Math_MathController.myScore',
  'post /v1/math/removescore': 'math/Math_MathController.removeScore',
  'post /v1/math/desc_energy': 'math/Math_MathController.descEnergyAndIncExp',

  'post /v1/math/getchallenge': 'math/Math_MathController.getChallenge',
  'post /v1/math/addchallenge': 'math/Math_MathController.addChallenge',
  'post /v1/math/stopchallenge': 'math/Math_MathController.stopChallenge',
  'post /v1/math/mychallenges': 'math/Math_MathController.myChallenges',
  'post /v1/math/suggestchallenges': 'math/Math_MathController.suggestChallenges',
  'post /v1/math/acceptchallenge': 'math/Math_MathController.acceptChallenge',
  
  'post /v1/math/matchscore': 'math/Math_MathController.postMatchScore',
  
  // math item
  'post /v1/math/item/receive': 'math/Math_MathItemController.receive',
  'post /v1/math/item/use': 'math/Math_MathItemController.useOne',
  'post /v1/math/item/usereal': 'math/Math_MathItemController.showCode',
  'post /v1/math/item/combine': 'math/Math_MathItemController.combinePartialItem',
  'post /v1/math/item/myitems': 'math/Math_MathItemController.myItems',

  // math room
  'post /v1/math/room/nahi': 'math/Math_MathRoomController.listNahiRooms',
  'post /v1/math/room/list': 'math/Math_MathRoomController.listRooms',
  'post /v1/math/room/create': 'math/Math_MathRoomController.createRoom',
  'post /v1/math/room/watch': 'math/Math_MathRoomController.watchRoom',
  'post /v1/math/room/join': 'math/Math_MathRoomController.playRoom',
  'post /v1/math/room/autojoin': 'math/Math_MathRoomController.autoJoin',
  'post /v1/math/room/unjoin': 'math/Math_MathRoomController.jumpToWatcher',
  'post /v1/math/room/leave': 'math/Math_MathRoomController.leaveRoom',
  'post /v1/math/room/start': 'math/Math_MathRoomController.startRoom',
  'post /v1/math/room/terms': 'math/Math_MathRoomController.getTerms',
  'post /v1/math/room/score': 'math/Math_MathRoomController.score',
  'post /v1/math/room/misscore': 'math/Math_MathRoomController.misScore',
  'post /v1/math/room/backroom': 'math/Math_MathRoomController.backRoom',
  
  /**********************************************************
  * BRAIN API                                               *
  **********************************************************/
  
  // game
  'post /v1/brain/game/list': 'smart/Smart_GameController.brainList',

  // single 
  'post /v1/brain/single/start': 'brain/Brain_SingleMatchController.start',
  'post /v1/brain/single/end': 'brain/Brain_SingleMatchController.end',
  'post /v1/brain/single/getterm': 'brain/Brain_SingleMatchController.getTerms',

  /**********************************************************
  * DUEL API                                               *
  **********************************************************/

  // game
  'post /v1/duel/game/list': 'smart/Smart_GameController.duelList',

  /**********************************************************
  * ADMIN API                                               *
  **********************************************************/

  // auth
  'post /admin/auth/login': 'admin/Admin_AuthController.login',
  'post /admin/auth/logout': 'admin/Admin_AuthController.logout',

  // admin user
  'post /admin/adminuser/add': 'admin/Admin_AdminUserController.add',
  'post /admin/adminuser/update': 'admin/Admin_AdminUserController.update',
  'post /admin/adminuser/updateme': 'admin/Admin_AdminUserController.updateMe',
  'post /admin/adminuser/remove': 'admin/Admin_AdminUserController.remove',
  'post /admin/adminuser/profile': 'admin/Admin_AdminUserController.profile',
  'post /admin/adminuser/list': 'admin/Admin_AdminUserController.list',

  // admin user role
  'post /admin/role/add': 'admin/Admin_RoleController.add',
  'post /admin/role/update': 'admin/Admin_RoleController.update',
  'post /admin/role/remove': 'admin/Admin_RoleController.remove',
  'post /admin/role/view': 'admin/Admin_RoleController.view',
  'post /admin/role/list': 'admin/Admin_RoleController.list',
  'post /admin/role/listcombo': 'admin/Admin_RoleController.listCombo',

  // admin user permission
  'post /admin/permission/list': 'admin/Admin_PermissionController.list',
      
  // game
  'post /admin/game/list': 'admin/Admin_GameController.list',
  'post /admin/game/add': 'admin/Admin_GameController.add',
  'post /admin/game/remove': 'admin/Admin_GameController.remove',
  'post /admin/game/update': 'admin/Admin_GameController.update',
  'post /admin/game/status': 'admin/Admin_GameController.status',
  'post /admin/game/listcombo': 'admin/Admin_GameController.listCombo',
  'post /admin/game/brainList': 'admin/Admin_GameController.brainList',

  // game category 
  'post /admin/gamecategory/list': 'admin/Admin_GameCategoryController.list',
  'post /admin/gamecategory/add': 'admin/Admin_GameCategoryController.add',
  'post /admin/gamecategory/remove': 'admin/Admin_GameCategoryController.remove',
  'post /admin/gamecategory/update': 'admin/Admin_GameCategoryController.update',
  'post /admin/gamecategory/status': 'admin/Admin_GameCategoryController.status',

  // item
  'post /admin/item/list': 'admin/Admin_ItemController.list',
  'post /admin/item/add': 'admin/Admin_ItemController.create',
  'post /admin/item/view': 'admin/Admin_ItemController.get',
  'post /admin/item/update': 'admin/Admin_ItemController.update',
  'post /admin/item/status': 'admin/Admin_ItemController.status',
  'post /admin/item/listcombo': 'admin/Admin_ItemController.listCombo',

  // user manager
  'post /admin/user/list': 'admin/Admin_UserController.list',
  'post /admin/user/view': 'admin/Admin_UserController.view',
  'post /admin/user/bucket': 'admin/Admin_UserController.buckets',

  // admin template
  'post /admin/notification_template/list': 'admin/Admin_NotificationTemplateController.list',
  'post /admin/notification_template/add': 'admin/Admin_NotificationTemplateController.add',
  'post /admin/notification_template/update': 'admin/Admin_NotificationTemplateController.update',
  'post /admin/notification_template/remove': 'admin/Admin_NotificationTemplateController.remove',
  'post /admin/notification_template/active': 'admin/Admin_NotificationTemplateController.active',
 
  // user log
  'post /admin/userlog/list': 'admin/Admin_UserLogController.list',
  'post /admin/userlog/view': 'admin/Admin_UserLogController.view',
  
  // report
  'post /admin/report/star': 'admin/Admin_ReportController.starReport',
  'post /admin/report/exp': 'admin/Admin_ReportController.expReport',
  'post /admin/report/energy': 'admin/Admin_ReportController.energyReport',
  'post /admin/report/money': 'admin/Admin_ReportController.moneyReport',
  'post /admin/report/time': 'admin/Admin_ReportController.timeReport',
  
  // bucket log
  'post /admin/log/bucket': 'admin/Admin_BucketLogController.list',

  // exchange
  'post /admin/exchange/item/list': 'admin/Admin_ExchangeController.listItems',
  'post /admin/exchange/item/add': 'admin/Admin_ExchangeController.addItems',
  'post /admin/exchange/item/update': 'admin/Admin_ExchangeController.updateItems',
  'post /admin/exchange/item/remove': 'admin/Admin_ExchangeController.removeItems',

    // stores category
  'post /admin/store/category/list': 'admin/Admin_StoreCategoryController.list',
  'post /admin/store/category/add': 'admin/Admin_StoreCategoryController.add',
  'post /admin/store/category/update': 'admin/Admin_StoreCategoryController.update',
  'post /admin/store/category/remove': 'admin/Admin_StoreCategoryController.remove',

  // Discount
  'post /admin/discount/list': 'admin/Admin_DiscountController.list',
  'post /admin/discount/add': 'admin/Admin_DiscountController.add',
  'post /admin/discount/update': 'admin/Admin_DiscountController.update',
  'post /admin/discount/remove': 'admin/Admin_DiscountController.remove',

  // config
  'post /admin/config/get': 'admin/Admin_ConfigurationController.get',
  'post /admin/config/update': 'admin/Admin_ConfigurationController.update',
   
  /**********************************************************
  * BRAIN ADMIN API                                               *
  **********************************************************/

  // image
  'post /admin/brain/image/list': 'admin/BrainAdmin_ImageController.list',
  'post /admin/brain/image/add': 'admin/BrainAdmin_ImageController.add',
  'post /admin/brain/image/remove': 'admin/BrainAdmin_ImageController.remove',
  'post /admin/brain/image/update': 'admin/BrainAdmin_ImageController.update',

  // image category
  'post /admin/brain/imagecategory/list': 'admin/BrainAdmin_ImageCategoryController.list',
  'post /admin/brain/imagecategory/add': 'admin/BrainAdmin_ImageCategoryController.add',
  'post /admin/brain/imagecategory/remove': 'admin/BrainAdmin_ImageCategoryController.remove',
  'post /admin/brain/imagecategory/update': 'admin/BrainAdmin_ImageCategoryController.update',

  // Tim Bong Quiz
  'post /admin/dungnoi/quiz/list': 'admin/BrainAdmin_DungNoiQuizController.list',
  'post /admin/dungnoi/quiz/add': 'admin/BrainAdmin_DungNoiQuizController.add',
  'post /admin/dungnoi/quiz/remove': 'admin/BrainAdmin_DungNoiQuizController.remove',
  'post /admin/dungnoi/quiz/update': 'admin/BrainAdmin_DungNoiQuizController.update',

  // Tim Bong Quiz
  'post /admin/timbong/quiz/list': 'admin/BrainAdmin_TimBongQuizController.list',
  'post /admin/timbong/quiz/add': 'admin/BrainAdmin_TimBongQuizController.add',
  'post /admin/timbong/quiz/remove': 'admin/BrainAdmin_TimBongQuizController.remove',
  'post /admin/timbong/quiz/update': 'admin/BrainAdmin_TimBongQuizController.update',

  // Phan Biet Hinh Chu Quiz
  'post /admin/phanbiethinhchu/quiz/list': 'admin/BrainAdmin_PhanBietHinhChuQuizController.list',
  'post /admin/phanbiethinhchu/quiz/add': 'admin/BrainAdmin_PhanBietHinhChuQuizController.add',
  'post /admin/phanbiethinhchu/quiz/remove': 'admin/BrainAdmin_PhanBietHinhChuQuizController.remove',
  'post /admin/phanbiethinhchu/quiz/update': 'admin/BrainAdmin_PhanBietHinhChuQuizController.update',

  // Game Nhanh Mat Bat Hinh
  'post /admin/nhanhmatbathinh/quiz/list': 'admin/BrainAdmin_NhanhMatBatHinhQuizController.list',
  'post /admin/nhanhmatbathinh/quiz/add': 'admin/BrainAdmin_NhanhMatBatHinhQuizController.add',
  'post /admin/nhanhmatbathinh/quiz/update': 'admin/BrainAdmin_NhanhMatBatHinhQuizController.update',
  'post /admin/nhanhmatbathinh/quiz/remove': 'admin/BrainAdmin_NhanhMatBatHinhQuizController.remove',
  'post /admin/nhanhmatbathinh/quiz/active': 'admin/BrainAdmin_NhanhMatBatHinhQuizController.active',

  /**********************************************************
  * WEB API                                                 *
  **********************************************************/

  // energy
  'post /webapi/energy/retrieve': 'web/Web_EnergyController.getEnergy',
  'post /webapi/energy/add': 'web/Web_EnergyController.addEnergy',
  'post /webapi/energy/use': 'web/Web_EnergyController.useEnergy',
 
  // item
  'post /webapi/item': 'smart/Smart_ItemController.listItems',
  'post /webapi/item/add': 'smart/Smart_ItemController.createItem',
  'post /webapi/item/view': 'smart/Smart_ItemController.getItem',
  'post /webapi/item/update': 'smart/Smart_ItemController.updateItem',
  'post /webapi/item/enable': 'smart/Smart_ItemController.enableItem',
  'post /webapi/item/disable': 'smart/Smart_ItemController.disableItem',

  'post /webapi/bucket/me': 'smart/Smart_BucketController.getMyBucket',
  'post /webapi/bucket/viewitem': 'smart/Smart_BucketController.getBucketItem',
  'post /webapi/bucket/add': 'smart/Smart_BucketController.addItemToBucket',
  'post /webapi/bucket/use': 'smart/Smart_BucketController.useItemOnBucket',

  // donate
  'post /webapi/donate': 'web/Web_DonationController.webTransferStarsToFriend',

};