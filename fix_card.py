# -*- coding: utf-8 -*-
import re
from pathlib import Path
p=Path('lib/pages/card_details/card_details_widget.dart')
t=p.read_text(encoding='utf-8', errors='replace')
t=re.sub(r"text: '.*Wallet'","text: 'عرض الباس في Wallet'",t,1)
t=re.sub(r"text: _model.isCreatingPass\s*\?\s*'.*?'\s*:\s*'.*?Apple Wallet'","text: _model.isCreatingPass ? '...جاري إنشاء الباس' : 'إضافة إلى Apple Wallet'",t,1)
t=t.replace('������ �������','تفاصيل البطاقة')
p.write_text(t, encoding='utf-8')
