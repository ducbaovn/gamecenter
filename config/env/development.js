/**
 * Development environment settings
 *
 * This file can include shared settings for a development team,
 * such as API keys or remote database passwords.  If you're using
 * a version control solution for your Sails app, this file will
 * be committed to your repository unless you add it to your .gitignore
 * file.  If your repository will be publicly viewable, don't add
 * any private information to this file!
 *
 */
var FACEBOOK_CONFIG = {
};

var GOOGLE_CONFIG = {
};

var AMQP_CONFIG = {
};

var GCM_CONFIG = {
};

var APN_CONFIG = {
};

var REDIS_CONNECTION = {
};

module.exports = {

  /***************************************************************************
   * Set the default database connection for models in the development       *
   * environment (see config/connections.js and config/models.js )           *
   ***************************************************************************/

  models: {
    connection: 'gcMongoDev',
    migrate: 'alter'
  },
  facebook: FACEBOOK_CONFIG,
  google: GOOGLE_CONFIG,
  tokenTimeout: 525600, // in minutes
  amqp: AMQP_CONFIG,
  gcm: GCM_CONFIG,
  apn: APN_CONFIG,
  redis: REDIS_CONNECTION
};
