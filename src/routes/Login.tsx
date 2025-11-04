import { useState } from "react";
import { supabase } from "../lib/supabase";
import { useNavigate } from "react-router-dom";

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const nav = useNavigate();

  const signIn = async () => {
    console.log("Attempting login with:", email);
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) {
      console.error("Login error:", error);
      return alert(error.message);
    }
    console.log("Login successful:", data);
    nav("/");
  };

  return (
    <div
      style={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "linear-gradient(135deg, #1a202c 0%, #2d3748 100%)",
      }}
    >
      <div
        style={{
          background: "rgba(45, 55, 72, 0.85)",
          backdropFilter: "blur(10px)",
          padding: 40,
          borderRadius: 16,
          boxShadow: "0 15px 35px rgba(0,0,0,0.3)",
          border: "1px solid rgba(255,255,255,0.1)",
          width: "100%",
          maxWidth: 400,
        }}
      >
        <h2
          style={{
            marginTop: 0,
            marginBottom: 32,
            textAlign: "center",
            color: "#e2e8f0",
          }}
        >
          Auto Appraisal Login
        </h2>
        <div style={{ display: "grid", gap: 16 }}>
          <div>
            <label
              style={{
                display: "block",
                marginBottom: 8,
                fontWeight: "bold",
                color: "#e2e8f0",
              }}
            >
              Email
            </label>
            <input
              placeholder="Enter your email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              style={{
                width: "100%",
                padding: 12,
                fontSize: 16,
                border: "1px solid #4a5568",
                borderRadius: 6,
                boxSizing: "border-box",
                background: "#2d3748",
                color: "#e2e8f0",
              }}
            />
          </div>
          <div>
            <label
              style={{
                display: "block",
                marginBottom: 8,
                fontWeight: "bold",
                color: "#e2e8f0",
              }}
            >
              Password
            </label>
            <input
              placeholder="Enter your password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              style={{
                width: "100%",
                padding: 12,
                fontSize: 16,
                border: "1px solid #4a5568",
                borderRadius: 6,
                boxSizing: "border-box",
                background: "#2d3748",
                color: "#e2e8f0",
              }}
            />
          </div>
          <button
            onClick={signIn}
            style={{
              width: "100%",
              padding: 14,
              fontSize: 16,
              fontWeight: "bold",
              background: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
              color: "white",
              border: "none",
              borderRadius: 6,
              cursor: "pointer",
              marginTop: 8,
            }}
            onMouseOver={(e) =>
              (e.currentTarget.style.background =
                "linear-gradient(135deg, #764ba2 0%, #667eea 100%)")
            }
            onMouseOut={(e) =>
              (e.currentTarget.style.background =
                "linear-gradient(135deg, #667eea 0%, #764ba2 100%)")
            }
          >
            Sign In
          </button>
        </div>
      </div>
    </div>
  );
}
