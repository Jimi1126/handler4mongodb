DBProxy = require "./DBProxy"
DBHandler = require "./DBHandler"
##
# dao定义.
##
class MongoDao
	###
	# 构造函数.
	# @param config 目标数据库的相关配置
	# @param cont 目标库与表
	###
	constructor: (config, cont)->
		throw "未进行数据库配置" unless config
		throw "请传入实例化库和集合" unless cont
		perfix = "mongodb://#{config.username}:#{config.password}@#{config.hostName}:#{config.port}/"
		postfix = "?#{config.auth}"
		for k, v of cont
			@[k] = {}
			unless Array.isArray v
				@[k][v] = new DBProxy (new DBHandler perfix + k + postfix, v, config.DB_OPTS)
			else
				for col in v
					@[k][col] = new DBProxy (new DBHandler perfix + k + postfix, col, config.DB_OPTS)

module.exports = MongoDao
