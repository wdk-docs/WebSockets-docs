# ws

## 使用

```sh
pip install sphinx
pip install sphinx-autobuild
sphinx-autobuild source docs
```

## 国际翻译

> https://www.sphinx-doc.org/zh_CN/master/usage/advanced/intl.html

1. 安装 `sphinx-intl`.

   ```sh
      pip install sphinx-intl
   ```

2. 将配置添加到 `conf.py`.

   ```
   locale_dirs = ['locale/'] # path is example but recommended.
   gettext_compact = False # optional.
   ```

   这个案例研究假设 BUILDDIR 被设置为 `build` ：confval:`locale_dirs`被设置为 `locale/` 并且：confval:`gettext_compact`被设置为`False ``（Sphinx 文档已经这样配置）。

3. 将可翻译的消息提取到 pot 文件中。

   make gettext
   生成的 pot 文件将被放在`u build/gettext`目录中。

4. 生成采购订单文件。

   我们将使用上述步骤中生成的 pot 文件。

   sphinx-intl update -p \_build/gettext -l de -l ja
   完成后，生成的采购订单文件将放在以下目录中：

   ./locale/de/LC_MESSAGES/

   ./locale/ja/LC_MESSAGES/

5. 翻译采购订单文件。

   As noted above, these are located in the ./locale/<lang>/LC_MESSAGES directory. An example of one such file, from Sphinx, builders.po, is given below.

   ```
   # a5600c3d2e3d48fc8c261ea0284db79b
   #: ../../builders.rst:4
   msgid "Available builders"
   msgstr "<FILL HERE BY TARGET LANGUAGE>"
   ```

   另一种情况是，msgid 是多行文本，并包含 restructedText 语法：

   ```
   # 302558364e1d41c69b3277277e34b184
   #: ../../builders.rst:9
   msgid ""
   "These are the built-in Sphinx builders. More builders can be added by "
   ":ref:`extensions <extensions>`."
   msgstr ""
   "FILL HERE BY TARGET LANGUAGE FILL HERE BY TARGET LANGUAGE FILL HERE "
   "BY TARGET LANGUAGE :ref:`EXTENSIONS <extensions>` FILL HERE."
   ```

   请注意不要破坏 reST 符号。大多数 po 编辑都会帮你。

6. 生成翻译文档。

   您需要一个：confval:`language`参数`conf.py`也可以在命令行中指定参数。

   对于 For BSD/GNU make，运行：

   make -e SPHINXOPTS="-D language='de'" html
   对于 Windows:命令：命令提示符，运行：

   > set SPHINXOPTS=-D language=de
   > .\make.bat html
   > 为 PowerShell 运行：

   > Set-Item env:SPHINXOPTS "-D language=de"
   > .\make.bat html

祝贺你！翻译后的文档在`build/html`目录下。

## sphinx-js

> https://github.com/mozilla/sphinx-js

Install JSDoc (or TypeDoc if you're writing TypeScript). 
The tool must be on your $PATH, so you might want to install it globally:

```sh
npm install -g jsdoc
...or...

npm install -g typedoc
```

JSDoc 3.6.3 and TypeDoc 0.15.0 are known to work.

Install sphinx-js, which will pull in Sphinx itself as a dependency:
```sh
pip install sphinx-js
```
Make a documentation folder in your project by running sphinx-quickstart and answering its questions:
```sh
cd my-project
```
sphinx-quickstart
```
> Root path for the documentation [.]: docs
> Separate source and build directories (y/n) [n]:
> Name prefix for templates and static dir [_]:
> Project name: My Project
> Author name(s): Fred Fredson
> Project version []: 1.0
> Project release [1.0]:
> Project language [en]:
> Source file suffix [.rst]:
> Name of your master document (without suffix) [index]:
> Do you want to use the epub builder (y/n) [n]:
> autodoc: automatically insert docstrings from modules (y/n) [n]:
> doctest: automatically test code snippets in doctest blocks (y/n) [n]:
> intersphinx: link between Sphinx documentation of different projects (y/n) [n]:
> todo: write "todo" entries that can be shown or hidden on build (y/n) [n]:
> coverage: checks for documentation coverage (y/n) [n]:
> imgmath: include math, rendered as PNG or SVG images (y/n) [n]:
> mathjax: include math, rendered in the browser by MathJax (y/n) [n]:
> ifconfig: conditional inclusion of content based on config values (y/n) [n]:
> viewcode: include links to the source code of documented Python objects (y/n) [n]:
> githubpages: create .nojekyll file to publish the document on GitHub pages (y/n) [n]:
> Create Makefile? (y/n) [y]:
> Create Windows command file? (y/n) [y]:
> In the generated Sphinx conf.py file, turn on sphinx_js by adding it to extensions:
```
```
extensions = ['sphinx_js']
```
If you want to document TypeScript, add js_language = 'typescript' to conf.py as well.

If your JS source code is anywhere but at the root of your project, add js_source_path = '../somewhere/else' on a line by itself in conf.py. The root of your JS source tree should be where that setting points, relative to the conf.py file. (The default, ../, works well when there is a docs folder at the root of your project and your source code lives directly inside the root.)

If you have special JSDoc or TypeDoc configuration, add jsdoc_config_path = '../conf.json' (for example) to conf.py as well.

If you're documenting only JS or TS and no other languages (like C), you can set your "primary domain" to JS in conf.py:
```
primary_domain = 'js'
```
(The domain is js even if you're writing TypeScript.) Then you can omit all the "js:" prefixes in the directives below.
