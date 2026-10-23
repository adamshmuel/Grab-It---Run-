# דגמי חפצים לבדיקה חזותית

שלושה דגמים מקומיים בפורמט של Roblox, כהצעה חזותית ולא כמימוש מאושר של המשחק. המקור הוא קובצי model.json. קובצי project.json מאפשרים לייצר מכל אחד קובץ rbxmx שאפשר להשתמש בו בתוך Studio. לא נדרשת התקנה, רכישה או תמונה חיצונית.

| דגם | צורה | גודל בפועל לפי קובץ הייצוא | חלקים וצבעים |
| --- | --- | --- | --- |
| WoodCrate | ארגז קטן, לוחות, רצועות ופינות | רוחב 1.74, גובה 1.8, עומק 1.82 studs | 10 חלקים, 4 צבעים |
| ToolCase | מזוודה רחבה עם מכסה, ידית וסוגרים | רוחב 2.45, גובה 2.04, עומק 1.875 studs | 9 חלקים, 7 צבעים |
| EnergyCanister | מכל גלילי גבוה עם מכסה, טבעות וידית | רוחב 2.1, גובה 2.925, עומק 2.1 studs | 10 חלקים, 6 צבעים |

כל החלקים מקובעים ואינם מתנגשים. אין בדגמים scripts או הפניות לתוכן חיצוני. הם עדיין לא מחוברים לאיסוף או למטען. התאמה למיקום, הסתרה אישית ונשיאה יבוצעו רק במסגרת ההגדרה ותוכנית המימוש המאושרות.

## שחזור הקבצים

מתוך תיקיית הפרויקט, שלוש הפקודות יוצרות את קובצי הדגמים בתוך build:

```sh
rojo build assets/prototypes/collectibles/wood-crate.project.json -o build/VisualPrototype_WoodCrate.rbxmx
rojo build assets/prototypes/collectibles/tool-case.project.json -o build/VisualPrototype_ToolCase.rbxmx
rojo build assets/prototypes/collectibles/energy-canister.project.json -o build/VisualPrototype_EnergyCanister.rbxmx
```

בתאריך 23/10/2026 הייצוא עבר באמצעות Rojo 7.7.1. בדיקת XML אישרה גדלים, צבעים, שמירת צורת Cylinder והיעדר scripts. התוצאות נשמרו בתוך docs/research/evidence/v1/native-visual-prototypes.json. אין עדיין צילום Studio, אישור חזותי או הוכחת ביצועים. אין להציג את הדגמים כאילו כבר עברו השוואה למתחרים.
