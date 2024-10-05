{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ firejail ];
  
  programs.firejail.enable = true;
  programs.firejail.wrappedBinaries = {
    anydesk = {
      executable = "${pkgs.anydesk}/bin/anydesk";
      profile = "/etc/firejail/anydesk.profile";
    };
  };
}
