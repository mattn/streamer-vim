function! streamer#start()
  let username = get(g:, 'streamer#username', input('Username: '))
  if len(username) == 0 | return | endif
  let password = get(g:, 'streamer#password', inputsecret('Password: '))
  if len(password) == 0 | return | endif

  let cmd  = printf("curl -s -u %s:%s %s",
  \  username,
  \  password,
  \  "https://stream.twitter.com/1.1/statuses/sample.json")
  let s:proc = vimproc#plineopen2(cmd)
  augroup Streamer
    autocmd!
    autocmd CursorHold,CursorHoldI * call streamer#poll()
  augroup END
  call streamer#poll()
endfunction

function! streamer#poll()
  try
    let content = s:proc.stdout.read_line()
    if content != ''
      let status = webapi#json#decode(content)
      let &titlestring = status.user.screen_name . ' ' .  status.text
      redraw
    endif
  catch
  finally
    call feedkeys(mode() ==# 'i' ? "\<C-g>\<ESC>" : "g\<ESC>", 'n')
  endtry
endfunction
