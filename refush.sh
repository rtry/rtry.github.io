echo '======从有道中导出文件======'
java ExportYNoteUtil
echo '======导出完成...==========='

echo '======正在生成文件=========='
hexo g
echo '======文件完成...==========='

echo '======正在启动服务=========='
hexo s
