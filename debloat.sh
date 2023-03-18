#!/sbin/sh
LIST="AndroidAutoStub, BuiltInPrintService, CallLogBackup, CarrierDefaultApp, CarrierServices, CatchLog, Cit, Email, Eleven, Gallery2, GoogleCalendarSyncAdapter, GoogleContactsSyncAdapter, FileExplorer, GoogleLens, GoogleLocationHistory, BookmarkProvider, GooglePartnerSetup, GooglePrintRecommendationService, HotwordEnrollmentOKGoogleHEXAGON, HotwordEnrollmentXGoogleHEXAGON, Jelly, Joyose, LatinIME, MiBrowserGlobal, LatinImeGoogle, MiuiBugReport, ManagedProvisioning, MiGalleryLockscreen, GoogleFeedback, MiMover, MiuiVideoGlobal, ModemTestBox, OneTimeInitializer, PrebuiltExchange3Google, SensorTestTool, SetupWizard, SpeechServicesByGoogle, Stk, Traceur, Velvet, messaging, talkback, XMSFKeeper, wps-lite, OmniJaws, GoogleOneTimeInitializer, Joyose, Updater"
SYSTEM=""
PRODUCT="/product"

LOG_FOLDER="/sdcard/Entaytion"
LOG_FILE="$LOG_FOLDER/debloat_$(date '+%Y-%m-%d_%H-%M-%S').log"
mkdir -p "$LOG_FOLDER"
echo "- Папка создана: $LOG_FOLDER" >> "$LOG_FILE"

if [ -d "/system_root" ]; then
    SYSTEM="/system_root"
elif [ -d "/system" ]; then
    SYSTEM="/system"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Ошибка! Система не может быть найдена." >> "$LOG_FILE"
    exit 1
fi
mount -t auto "$SYSTEM"
mount -o rw,remount "$SYSTEM"
mount -t auto "$PRODUCT"
mount -o rw,remount "$PRODUCT"
echo "$(date '+%Y-%m-%d %H:%M:%S'): Система смонтирована в: $SYSTEM" >> "$LOG_FILE"

if [ -z "$LIST" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Ошибка! Отсутствует список приложений." >> "$LOG_FILE"
    exit 1
fi

REMOVED=""
NOT_REMOVED=""
for APP_NAME in $(echo "$LIST" | tr ',' '\n'); do
    APP_PATHS=()
    for path in "$SYSTEM/app" "$SYSTEM/product/app" "$SYSTEM/priv-app" "$SYSTEM/product/priv-app" "$SYSTEM/vendor/app" "$PRODUCT/app" "$PRODUCT/priv-app"; do
        if [ -d "$path/$APP_NAME" ]; then
            APP_PATHS+=("$path/$APP_NAME")
        fi
    done

    if [ ${#APP_PATHS[@]} -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): $APP_NAME не было найдено." >> "$LOG_FILE"
        NOT_REMOVED="$NOT_REMOVED, $APP_NAME"
    elif [ ${#APP_PATHS[@]} -eq 1 ]; then
        rm -rf "${APP_PATHS[0]}"
        REMOVED="$REMOVED, $APP_NAME"
        echo "$(date '+%Y-%m-%d %H:%M:%S'): $APP_NAME удалён в: ${APP_PATHS[0]}." >> "$LOG_FILE"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S'): $APP_NAME найден в нескольких местах:" >> "$LOG_FILE"
        for APP_PATH in "${APP_PATHS[@]}"; do
            echo "$APP_PATH" >> "$LOG_FILE"
            rm -rf "$APP_PATH"
        done
        REMOVED="$REMOVED, $APP_NAME"
    fi
done


if [ -n "$REMOVED" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Эти папки были успешно удалены: ${REMOVED:2}." >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Нет папок, которые нужно удалить." >> "$LOG_FILE"
fi
if [ -n "$NOT_REMOVED" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Эти папки не были удалены: ${NOT_REMOVED:2}." >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Все папки успешно удалены." >> "$LOG_FILE"
fi

umount "$SYSTEM"
echo "$(date '+%Y-%m-%d %H:%M:%S'): Система отмонтирована в: $SYSTEM" >> "$LOG_FILE"
exit 0