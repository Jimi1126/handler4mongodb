import json from 'rollup-plugin-json';
import resolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';
import { terser } from 'rollup-plugin-terser';
import pkg from './package.json'

export default {
  input: './src/MongoDao.js',
  output: [
    { file: pkg.main, format: 'cjs' }
  ],
  plugins: [
    json(),
    commonjs(),
    resolve({
      // 将自定义选项传递给解析插件
      customResolveOptions: {
        moduleDirectory: 'node_modules'
      }
    }),
    terser()
  ],
  // 指出应将哪些模块视为外部模块
  external: Object.keys(pkg.dependencies)
}