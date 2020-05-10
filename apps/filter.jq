reduce .[] as $i (
{}
; reduce ($i|keys[]) as $k (
.
; if .[$k] == null then .[$k] = $i[$k] else . end
)
)
