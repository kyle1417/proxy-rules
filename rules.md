# .rules
- 所有 Surge 规则文件使用 .list 扩展名，每行一条规则
- 所有 Clash 规则文件使用 .yaml 格式，payload 数组结构
- 新增规则时，surge 和 clash 两个目录必须同步更新
- 不要修改 scripts/update.sh 的上游规则下载 URL，除非我明确要求