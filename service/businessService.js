var businessDao = require(ROOT + 'dao/businessDao');
var businessAddressDao = require(ROOT + 'dao/businessAddressDao');
var businessImageDao = require(ROOT + 'dao/businessImageDao');
var businessPromotionDao = require(ROOT + 'dao/businessPromotionDao');
var businessReviewDao = require(ROOT + 'dao/businessReviewDao');


exports.insert = function(business, callback){
	businessDao.insert(business, callback);
}
