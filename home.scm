;;; Copyright © 2025 Nikita Mitasov <mitanick@ya.ru>
(use-modules (gnu home)
             (gnu packages)
             (gnu home services)
	     (gnu services)
             (gnu home services sound)
             (gnu home services desktop)
             (gnu home services dotfiles)
             (gnu home services gnupg)
             (guix gexp)
             (guix packages)
             (guix download)
	     (nonguix utils)
             (nongnu packages nvidia)
             (gnu home services shepherd))

(define (home-dir)
  (getenv "HOME"))

(define (xdg-data-home)
  (or (getenv "XDG_DATA_HOME")
      (string-append home-dir "/.local/share")))

(define config-root
  (let* ((source-file (current-filename))
         (abs-path (canonicalize-path source-file)))
    (dirname abs-path)))

(with-transformation replace-mesa
		     (home-environment
		      (packages (load "packages.scm"))

		      (services
		       (append (list (service home-dbus-service-type)
				     (service home-pipewire-service-type)
				     (service home-gpg-agent-service-type
					      (home-gpg-agent-configuration
					       (pinentry-program
						(file-append (specification->package "pinentry") "/bin/pinentry"))
					       (ssh-support? #t)))
				     (simple-service 'env-vars-service
						     home-environment-variables-service-type
						     `(("TERM" . "xterm-256color")
						       ("NIXPKGS_ALLOW_UNFREE" . "1")
						       ("WLR_BACKENDS" . "libinput,drm")
						       ("PATH" . ,(string-append (dirname config-root) "/guixsd-config/bin:$PATH"))))

				     (service home-dotfiles-service-type
					      (home-dotfiles-configuration (directories '("./dotfiles"))
									   (layout 'stow)
									   (packages '("fastfetch"
										       "kitty"
										       "mwc"
										       "nix"
										       "nvim"
										       "rofi"
										       "ssh"
										       "starship"
										       "quickshell"
										       "waybar"
										       "xdg-desktop-portal"
										       "zsh"))))
				     (service home-files-service-type
					      `((".wakatime/wakatime-cli" ,(file-append (specification->package "wakatime-cli") "/bin/wakatime-cli"))))

				     (simple-service 'nix-channel-init home-activation-service-type
						     #~(begin
							 (use-modules (guix gexp))
							 (system
							  "nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs")
							 (system "nix-channel --update"))))
			       %base-home-services))))
