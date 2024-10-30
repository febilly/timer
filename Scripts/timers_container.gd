extends GridContainer
class_name Timers

@export var desired_ratio := 16.0 / 9.0
@export var auto_adjust := true

func _process(delta: float) -> void:
    # 根据屏幕比例动态调整列数
    var width: float = get_viewport().size.x
    var height: float = get_viewport().size.y
    var screen_ratio: float = width / height
    
    var timer_count = get_child_count()

    # 先计算一个对象要占据多少横向空间
    var item_width = desired_ratio / screen_ratio

    # 之后我们就认为屏幕是1x1的矩形，而物品是item_width x 1的矩形

    # 找出哪条边是制约因素
    var is_height_constrained = item_width < 1.0

    # 如果是宽度制约，我们先把它旋转一下，方便后续统一作为高度制约处理，最后再转回来
    if not is_height_constrained:
        item_width = 1.0 / item_width

    # 计算所有物体共占多少空间
    var total_size = item_width * timer_count

    # 计算理想情况下的行数
    var ideal_rows = sqrt(total_size)

    # 先四舍五入试试？
    var target_rows = round(ideal_rows)

    # 不要有空行
    target_rows = min(target_rows, timer_count)

    if is_height_constrained:
        # 找到对应的列数
        var target_columns = ceil(timer_count / target_rows)
        columns = target_columns
    else:
        columns = target_rows