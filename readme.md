# 概述
本模块是针对mongoDB的CRUD操作进行封装的模块，你只需指定目标mongoDB的相关配置以及所操作的document，你将得到一个代理对象，为你提供mongoDB的相关操作，并支持日志记录.
# 开始
> npm install --save handler4mongodb
# 实例
```
const MongoDao = require("handler4mongodb");
const config = {
  "mongodb": {
		"username": "test", //用户名
		"password": "test", //密码
		"hostName": "127.0.0.1",  //数据库地址
		"port": "27017",  //端口
		"auth": "authSource=admin", //认证
		"DB_OPTS": {"useNewUrlParser": true, "useUnifiedTopology":true} //连接参数
	}
}
// 实例一个提供test库user表的操作代理对象
const dao = new MongoDao(config.mongodb, {test: ["user"]});
// 调用方式 对象.库名.表名.操作
dao.test.user.insert({name: "test"}, (err)=> {});
// 实例多个表操作代理对象
const dao = new MongoDao(config.mongodb, {test1: ["user1", "user2"], test2: ["user3"]});
// 调用方式 对象.库名.表名.操作
dao.test1.user1.insert({name: "test"}, (err)=> {});
dao.test1.user2.insert({name: "test"}, (err)=> {});
dao.test2.user3.insert({name: "test"}, (err)=> {});
...
```
# 优化
后续
# 更新日志
时间|版本|内容
--|--|--
2020/03/06|1.0.2|修复addOrUpdate操作缺少原子操作符$set，并更新测试样例；
2020/03/05|1.0.1|修复数据库会话提前关闭问题；CRUD改为批量操作；
2020/01/13|1.0.0|新增
# 免责声明
本工具仅用于学习交流使用，禁止用于商业用途，使用本工具所造成的的后果由使用者承担！ 有疑问请 mail to: xfqing_mid@163.com