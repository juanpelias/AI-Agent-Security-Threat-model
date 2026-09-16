OpenClaw security advisor: Exec approvals could outlive their reviewed working directory

The security advisory “Exec approvals could outlive their reviewed working directory” describes a flaw in privileged persistence and 
authorization scope within the OpenClaw agent’s framework execution approval system. Reusable exec approvals were improperly bound to 
the file system they were originally evaluated for, which allows the same approved command to be ran later in a different directory against 
files or repositories that the user had not reviewed. The vulnerable component in the advisory is OpenClaw’s “tools.exec/exec-approvals” and 
the engine’s local SQLite exec_approvals table for underlying state storage. This authorization module stores standing execution permissions 
and evaluates incoming tool calls from agents before handing off commands to the host environment. The most common target for attackers to 
pursue is the working directory (cwd) path supplied during subsequent agent tool executions, as well as using prompt payload text to steer 
the agent's file navigation and tool choices. This allows attackers to use things like untrusted repository files, malicious pull requests, 
or fetched web content to hijack the agent and use the pre authorized commands to impact the host machine. In order for an exploit to be 
carried out, it requires that an operator be previously granted an allow-always approval for a command in an initial workspace, and then 
the agent attempts to run the exact same command arguments within an unreviewed second directory independent of user approval. This is 
primarily caused by an authorization engine lookup schema that matched permissions exclusively on argv and binary identity while omitting 
cwd, which allowed standing grants to persist across the entire host filesystem. As a result of this, an agent operating in an unreviewed 
location could execute pre-approved, context-dependent commands with unintended read or write side effects. The flaw did not bypass the 
initial human approval requirement, since those commands were approved previously, just for a different workspace. OpenClaw fixed this 
in version 2026.8.1 by binding cwd alongside argv during grant creation, ensuring authorization checks fail when they previously wouldn’t 
and now trigger a new human approval prompt whenever the execution directory differs from the approved one. To test against regression, 
we can create /tmp/repo-a and /tmp/repo-b, approve ls -la as allow-always in /tmp/repo-a, confirm automatic execution in that same directory, 
and verify that executing ls -la in /tmp/repo-b triggers a mandatory human approval prompt. In this example, prompt injection is helpful rather 
than required or irrelevant since an agent can trigger this vulnerability through routine autonomous task navigation without external intervention. 
Indirect prompt injection provides a reliable vector for an attacker to force an agent into an unreviewed directory and intentionally exploit stale 
approvals. Through prompt injection, the attacker controls where the exploit is used to make the necessary commands be carried out maliciously 
unbeknownst to the user. Overall, this advisory displays the dangers of allowing too much access to the OpenClaw agent, especially when that access 
is unintended by the user. Verifying and securing the privileges of these agents is crucial if we want to maintain this technology secure from malicious 
attackers and this security advisory highlights an example of an exploitation that agents can carry out without any outside influence or prompt injection; 
simply because their privileges were misconfigured. 
