import { forwardRef, useEffect, useRef, type TextareaHTMLAttributes } from "react";
import { Textarea } from "@/components/ui/textarea";

export const AutosizeTextarea = forwardRef<
    HTMLTextAreaElement,
    TextareaHTMLAttributes<HTMLTextAreaElement>
>(function AutosizeTextarea(props, ref) {
    const innerRef = useRef<HTMLTextAreaElement | null>(null);

    function setRefs(el: HTMLTextAreaElement) {
        innerRef.current = el;
        if (typeof ref === "function") ref(el);
        else if (ref) ref.current = el;
    }

    useEffect(() => {
        const el = innerRef.current;
        if (!el) return;

        const resize = () => {
            el.style.height = "auto";
            el.style.height = `${el.scrollHeight}px`;
        };

        resize();

        el.addEventListener("input", resize);
        return () => el.removeEventListener("input", resize);
    }, []);

    return (
        <Textarea
            {...props}
            ref={setRefs}
            className={`resize-none overflow-hidden transition-all ${props.className ?? ""}`}
        />
    );
});
