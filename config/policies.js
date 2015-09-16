/**
 * Policy Mappings
 * (sails.config.policies)
 *
 * Policies are simple functions which run **before** your controllers.
 * You can apply one or more policies to a given controller, or protect
 * its actions individually.
 *
 * Any policy file (e.g. `api/policies/authenticated.js`) can be accessed
 * below by its filename, minus the extension, (e.g. "authenticated")
 *
 * For more information on how policies work, see:
 * http://sailsjs.org/#/documentation/concepts/Policies
 *
 * For more information on configuring policies, check out:
 * http://sailsjs.org/#/documentation/reference/sails.config/sails.config.policies.html
 */


module.exports.policies = {

  /***************************************************************************
  *                                                                          *
  * Default policy for all controllers and actions (`true` allows public     *
  * access)                                                                  *
  *                                                                          *
  ***************************************************************************/

  // '*': 'canAccess',
  
  /***********************************
  * SMART CONTROLLER                 *
  ***********************************/
  'smart/Smart_AuthController': {
    '*': 'canAccess',
    'logout': 'authenticated'
  },

  'smart/Smart_UserController': {
    '*': 'authenticated'
  },

  'smart/Smart_ConfigurationController': {
    '*': 'canAccess'
  },

  'smart/Smart_ItemController': {
    '*': 'canAccess'
  },

  'smart/Smart_BucketController': {
    '*': 'webAuth'
  },

  'smart/Smart_ScoreController': {
    '*': 'authenticated'
  },

  'smart/Smart_ChallengeController': {
    '*': 'authenticated'
  },
  
  'smart/Smart_NotificationController': {
    '*': 'authenticated'
  },

  'smart/Smart_FriendshipController': {
    '*': 'authenticated'
  },

  'smart/Smart_ImageController': {
    '*': 'canAccess'
  },

  'smart/Smart_GameController': {
    '*': 'authenticated'
  },

  'smart/Smart_GameCategoryController': {
    '*': 'authenticated'
  },

  'smart/Smart_LeaderboardController': {
    '*': 'authenticated'
  },

  /************************************
  * CHAT CONTROLLER                   *
  ************************************/
  'chat/Chat_ChatController': {
    '*': 'socketAuth',
    'messages': 'authenticated'
  },

  'chat/Chat_RoomController': {
    '*': 'socketAuth',
    'rooms': 'authenticated',
    'messages': 'authenticated'
  },

  /************************************
  * MATH CONTROLLER                   *
  ************************************/
  'math/Math_MathController': {    
    '*': 'authenticated'
  },

  'math/Math_MathRoomController': {
    '*': 'socketAuth',
    'listRooms': 'authenticated',
    'listNahiRooms': 'authenticated',
    'getTerms': 'authenticated'
  },

  'math/Math_MathItemController': {
    '*': 'authenticated'
  },

  /************************************
  * BRAIN CONTROLLER              *
  ************************************/

  'brain/Brain_SingleMatchController': {
    "*": 'authenticated'
  },

  /************************************
  * ADMIN CONTROLLER                  *
  ************************************/

  'admin/Admin_AdminUserController': {
    '*': 'adminAuth'
  },
  
  'admin/Admin_RoleController': {
    '*': 'adminAuth'
  },

  'admin/Admin_PermissionController':{
    '*': 'adminAuth'
  },

  'admin/Admin_UserController': {
    '*': 'adminAuth'
  },
  
  'admin/Admin_GameController': {
    '*': 'adminAuth'
  },

  'admin/Admin_GameCategoryController': {
    '*': 'adminAuth'
  },

  'admin/Admin_ItemController': {
    '*': 'adminAuth'
  },

  'admin/Admin_NotificationTemplateController': {
    "*": 'adminAuth'
  },

  'admin/Admin_ReportController': {
    "*": 'adminAuth'
  },

  'admin/Admin_UserLogController': {
    "*": 'adminAuth'
  },

  'admin/Admin_BucketLogController': {
    "*": 'adminAuth'
  },

  'admin/Admin_ConfigurationController': {
    "*": 'adminAuth'
  },

  /************************************
  * BRAIN WAR CONTROLLER              *
  ************************************/
  'admin/BrainAdmin_ImageController': {
    "*": 'adminAuth'
  },

  'admin/BrainAdmin_ImageCategoryController': {
    "*": 'adminAuth'
  },

  'admin/BrainAdmin_PhanBietHinhChuQuizController': {
    "*": 'adminAuth'
  },

  'admin/BrainAdmin_TimBongQuizController': {
    "*": 'adminAuth'
  },
  
  'admin/BrainAdmin_NhanhMatBatHinhQuizController': {
    "*": 'adminAuth'
  },

  'admin/BrainAdmin_DungNoiQuizController': {
    "*": 'adminAuth'
  },
  
  /************************************
  * WEB CONTROLLER                    *
  ************************************/
  'web/Web_EnergyController': {
    '*': 'webAuth'
  },

  'web/Web_DonationController': {
    'webTransferStarsToFriend': 'webAuth',
    'gcTransferStarsToFriend': 'authenticated'
  }

};
