#!/bin/bash

# zshフォルダ -> $HOME/.ファイル名
if [ -d "$DOTFILES_DIR/zsh" ]; then
    # ループ設定の変更（サブシェルで実行して影響範囲を限定）
    (
        # ドットファイル(.zshrcなど)も * に含める
        shopt -s dotglob
        # マッチするファイルがない場合はループを回さない
        shopt -s nullglob

        for file in "$DOTFILES_DIR"/zsh/*; do
            # ファイルが存在しない場合はスキップ（nullglobがあれば基本不要だが念のため）
            [ -e "$file" ] || continue
            
            # 除外リスト
            case "$(basename "$file")" in
                .DS_Store|README.md|.gitkeep) continue ;;
            esac

            filename="$(basename "$file")"
            
            # ファイル名がドットで始まっていなければドットをつける
            if [[ "$filename" == .* ]]; then
                target="$HOME/$filename"
            else
                target="$HOME/.$filename"
            fi
            
            # link_file 関数を実行
            link_file "$file" "$target"
        done
    )
fi