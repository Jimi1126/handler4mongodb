const assert = require("assert");
const MongoDao = require("../src/MongoDao");
const config = require("../config/config");

var diff = function(source, target) {
  if (source === target) return false;
  if (source === null || source === undefined) return true;
  if (target === null || target === undefined) return true;
  if (typeof source != typeof target) return true;
  if (source instanceof Array) {
    for (let i = 0, j = source.length; i < j; i++) {
      if(diff(source[i], target[i])) {
        return true;
      }
    }
  } else if (typeof source === "object") {
    for (let key in source) {
      if (diff(source[key], target[key])) {
        return true;
      }
    }
  } else {
    return !(source === target);
  }
  return false;
}

let dao = new MongoDao(config.mongodb, {test: ["user"]});
dao.test.user.insert({"_id":"5e16ec94069ad340241afa24","name":"张三0","id":0}, (err) => {});
describe("mongoDB常用操作测试，集合：test，文档集：user", ()=> {
  it(`查询测试，查询"张三0"（{"_id":"5e16ec94069ad340241afa24","name":"张三0","id":0}）`, (done)=> {
    dao.test.user.selectOne({name: "张三0"}, (err, doc)=> {
      if (err) {
        done(err);
      } else if (diff(JSON.parse(JSON.stringify(doc)), {"_id":"5e16ec94069ad340241afa24","name":"张三0","id":0})) {
        done(`查询结果：` + JSON.stringify(doc));
      } else {
        done();
      }
    });
  });
  it(`新增测试，新增“李四”（{"name":"李四","id":20}）`, (done)=> {
    dao.test.user.insert({"name":"李四","id":20}, (err) => {
      if (err) return done(err);
      dao.test.user.selectOne({"name":"李四","id":20}, (err, doc)=> {
        if (err) return done(err);
        if (doc && doc.name == "李四") return done();
        done(`查询结果：` + JSON.stringify(doc));
      });
    });
  });
  it(`更新测试，更新“李四”（{"name":"李四","id":20}）的ID为21`, (done)=> {
    dao.test.user.update({"name":"李四"}, {$set: {id: 21}}, (err) => {
      if (err) return done(err);
      dao.test.user.selectOne({"name":"李四"}, (err, doc)=> {
        if (err) return done(err);
        if (doc && doc.id == 21) return done();
        done(`查询结果：` + JSON.stringify(doc));
      });
    });
  });
  it(`删除测试，删除“李四”（{"name":"李四","id":20}）`, (done)=> {
    dao.test.user.delete({"name":"李四"}, (err) => {
      if (err) return done(err);
      dao.test.user.selectOne({"name":"李四"}, (err, doc)=> {
        if (err) return done(err);
        if (!doc) return done();
        done(`查询结果：` + JSON.stringify(doc));
      });
    });
  });
});