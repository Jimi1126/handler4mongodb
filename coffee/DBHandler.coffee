###
# mongoDB操作
# 对mongoDB原生方法进行一层封装，简化mongo数据库的操作
# 通过数据库链接、所连接集合、连接参数来实例化DB操作对象
# 一般的实例化对象提供增删改查操作
###
mongoClient = require('mongodb').MongoClient
InsertManyOptions = require('mongodb').InsertManyOptions
ObjectId = require('mongodb').ObjectId
async = require("async")
LOG = global["mongoLogger"] || console
class DBHandler
	constructor: (@url, @collection, @DB_OPTS)->
		@database = @url.substring @url.lastIndexOf("/") + 1, @url.lastIndexOf("?")
	# 数据库会话连接
	connect: (callback)->
		cb = (err, db) =>
			unless db
				LOG.error "数据库连接获取失败"
			try
				callback err, db.db(@database)
			catch e
				LOG.error e.stack
		try
			mongoClient.connect @url, @DB_OPTS, cb
		catch e
			LOG.error e.stack
	# 关闭连接
	closeConnectFun: (db, callback)->
		->
			db?.close?()
			(callback)?.apply null, arguments
	insert: (docs, callback) ->
		@connect (err, db) =>
			closeConnect = @closeConnectFun db, callback
			return closeConnect err if err
			if Array.isArray docs
				docs.forEach (d)->
					d._id and typeof d._id is "string" and (d._id = ObjectId(d._id))
				db.collection(@collection).insert docs, closeConnect
			else if docs instanceof Object
				docs._id and typeof docs._id is "string" and (docs._id = ObjectId(docs._id))
				db.collection(@collection).insertOne docs, closeConnect
			else
				closeConnect "param Invalid"
	addOrUpdate: (docs, callback) ->
		if docs instanceof Object or Array.isArray docs
			that = @
			@connect (err, db) =>
				return callback err if err
				if Array.isArray docs
					async.each docs, (doc, ccb)->
						doc._id and typeof doc._id is "string" and (doc._id = ObjectId(doc._id))
						db.collection(that.collection).findOne {_id: doc._id}, (err, result)->
							if result
								db.collection(that.collection).updateOne {_id: doc._id}, {$set: doc}, ccb
							else
								db.collection(that.collection).insertOne doc, ccb
					, (err)->
						db?.close?()
						callback err
				else if docs instanceof Object
					docs._id and typeof docs._id is "string" and (docs._id = ObjectId(docs._id))
					db.collection(that.collection).findOne {_id: docs._id}, (err, result)->
						if result
							db.collection(that.collection).updateOne {_id: docs._id}, {$set: docs}, (err)->
								db?.close?()
								callback err
						else
							db.collection(that.collection).insertOne docs, (err)->
								db?.close?()
								callback err
		else
			callback null
	delete: (param, callback) ->
		@connect (err, db) =>
			closeConnect = @closeConnectFun db, callback
			return closeConnect err if err
			param._id and typeof param._id is "string" and (param._id = ObjectId(param._id))
			db.collection(@collection).countDocuments param, (err, count)=>
				if count is 1
					db.collection(@collection).removeOne param, closeConnect
				else if count > 1
					db.collection(@collection).removeMany param, closeConnect
				else
					closeConnect null, 0
	update: (filter, setter, callback) ->
		@connect (err, db) =>
			closeConnect = @closeConnectFun db, callback
			return closeConnect err if err
			filter._id and typeof filter._id is "string" and (filter._id = ObjectId(filter._id))
			setter._id and delete setter._id
			db.collection(@collection).countDocuments filter, (err, count)=>
				if count is 1
					db.collection(@collection).updateOne filter, setter, closeConnect
				else if count > 1
					db.collection(@collection).updateMany filter, setter, closeConnect
				else
					closeConnect null, 0
	selectOne: (param, callback) ->
		@connect (err, db) =>
			closeConnect = @closeConnectFun db, callback
			return closeConnect err if err
			param._id and typeof param._id is "string" and (param._id = ObjectId(param._id))
			db.collection(@collection).findOne param, closeConnect
	selectBySortOrLimit: (param, sort, limit, callback) ->
		@connect (err, db) =>
			return callback err if err
			param._id and typeof param._id is "string" and (param._id = ObjectId(param._id))
			if limit is -1
				db.collection(@collection).find(param).sort(sort).toArray (err, docs)->
					db?.close?()
					callback err, docs
			else
				db.collection(@collection).find(param).sort(sort).limit(limit).toArray (err, docs)->
					db?.close?()
					callback err, docs
	selectBySortOrSkipOrLimit: (param, sort, skip, limit, callback) ->
		@connect (err, db) =>
			return callback err if err
			param._id and typeof param._id is "string" and (param._id = ObjectId(param._id))
			if limit is -1
				db.collection(@collection).find(param).skip(skip).sort(sort).toArray (err, docs)->
					db?.close?()
					callback err, docs
			else
				db.collection(@collection).find(param).skip(skip).limit(limit).sort(sort).toArray (err, docs)->
					db?.close?()
					callback err, docs
	selectList: (param, callback) ->
		@connect (err, db) =>
			return callback err if err
			param._id and typeof param._id is "string" and (param._id = ObjectId(param._id))
			db.collection(@collection).find(param).toArray (err, docs)->
				db?.close?()
				callback err, docs
	count: (param, callback) ->
		@connect (err, db) =>
			closeConnect = @closeConnectFun db, callback
			return closeConnect err if err
			param._id and typeof param._id is "string" and (param._id = ObjectId(param._id))
			db.collection(@collection).countDocuments param, closeConnect
	aggregate: ->
		[...params] = arguments
		return if !params.length
		callback = params.pop()
		@connect (err, db) =>
			closeConnect = @closeConnectFun db, callback
			params.push closeConnect
			return closeConnect err if err
			db.collection(@collection).aggregate.apply db.collection(@collection), params

module.exports = DBHandler
